class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_enrollment, except: [:stripe_webhook, :paypal_webhook, :success, :cancel, :paypal_success, :paypal_cancel]
  before_action :set_payment, only: [:success, :cancel, :paypal_success, :paypal_cancel, :bank_transfer_instructions, :upload_receipt]
  skip_before_action :verify_authenticity_token, only: [:stripe_webhook, :paypal_webhook]
  
  def new
    # Verificar que el usuario es el propietario de la inscripción
    unless @enrollment.user == current_user
      redirect_to root_path, alert: 'No estás autorizado para realizar esta acción.'
      return
    end
    
    @payment = @enrollment.payments.build(
      user: current_user,
      amount: @enrollment.course.price,
      status: :pending
    )
  end

  def create
    @payment = @enrollment.payments.build(payment_params)
    @payment.user = current_user
    @payment.amount = @enrollment.course.price
    @payment.status = :pending

    if @payment.save
      case @payment.payment_method
      when 'stripe'
        process_stripe_payment
      when 'paypal'
        process_paypal_payment
      when 'bank_transfer'
        redirect_to bank_transfer_instructions_course_enrollment_payment_path(
          @enrollment.course, 
          @enrollment, 
          @payment
        )
      else
        @payment.destroy
        flash.now[:alert] = 'Método de pago no válido.'
        render :new
      end
    else
      render :new
    end
  end

  def stripe_webhook
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      return head :bad_request
    end

    StripeService.handle_webhook(event)
    head :ok
  end

  def paypal_webhook
    if verify_paypal_webhook
      # Buscar el pago por el ID de transacción
      payment = Payment.find_by(transaction_id: params[:txn_id] || params[:parent_txn_id])
      
      if payment.present?
        case params[:payment_status]
        when "Completed"
          # Marcar el pago como completado si aún no lo está
          unless payment.completed?
            payment.mark_as_completed!
            payment.enrollment.update(status: :active)
            PaymentMailer.confirmation(payment).deliver_later
            Rails.logger.info("PayPal IPN: Payment #{payment.id} marked as completed")
          end
        when "Refunded", "Reversed"
          # Marcar el pago como reembolsado
          payment.update(status: :refunded)
          payment.enrollment.update(status: :refunded)
          # Aquí se podría enviar un correo de notificación de reembolso
          Rails.logger.info("PayPal IPN: Payment #{payment.id} marked as refunded")
        when "Failed", "Denied", "Expired"
          # Marcar el pago como fallido
          payment.update(status: :failed)
          Rails.logger.info("PayPal IPN: Payment #{payment.id} marked as failed")
        end
      else
        Rails.logger.warn("PayPal IPN: Payment not found for transaction ID #{params[:txn_id] || params[:parent_txn_id]}")
      end
    else
      Rails.logger.error("PayPal IPN: Verification failed")
    end
    
    # Siempre responder con OK para que PayPal no reintente
    head :ok
  end

  def success
    if @payment.completed?
      redirect_to course_path(@payment.enrollment.course), notice: 'Pago completado exitosamente. ¡Bienvenido al curso!'
    else
      # Actualizar el estado del pago si viene de Stripe
      if params[:payment_intent] && !@payment.completed?
        stripe_payment_intent = Stripe::PaymentIntent.retrieve(params[:payment_intent])
        if stripe_payment_intent.status == 'succeeded'
          @payment.update(transaction_id: params[:payment_intent], status: :completed)
          @payment.enrollment.update(status: :active)
          PaymentMailer.confirmation(@payment).deliver_later
          redirect_to course_path(@payment.enrollment.course), notice: 'Pago completado exitosamente. ¡Bienvenido al curso!'
          return
        end
      end
      
      redirect_to course_path(@payment.enrollment.course), alert: 'El estado del pago está pendiente de verificación.'
    end
  end

  def cancel
    @payment.update(status: :failed)
    redirect_to course_path(@payment.enrollment.course), alert: 'El pago ha sido cancelado.'
  end
  
  def paypal_success
    # Verificar el pago con PayPal
    if params[:paymentId] && params[:PayerID]
      begin
        # Ejecutar el pago con PayPal
        paypal_service = PaypalService.new(@payment)
        if paypal_service.execute_payment(params[:paymentId], params[:PayerID])
          @payment.update(transaction_id: params[:paymentId], status: :completed)
          @payment.enrollment.update(status: :active)
          PaymentMailer.confirmation(@payment).deliver_later
          redirect_to course_path(@payment.enrollment.course), notice: 'Pago completado exitosamente. ¡Bienvenido al curso!'
        else
          redirect_to course_path(@payment.enrollment.course), alert: 'Error al procesar el pago con PayPal.'
        end
      rescue => e
        Rails.logger.error("Error al procesar pago PayPal: #{e.message}")
        redirect_to course_path(@payment.enrollment.course), alert: 'Error al procesar el pago con PayPal. Por favor, inténtalo de nuevo.'
      end
    else
      redirect_to course_path(@payment.enrollment.course), alert: 'Error al procesar el pago con PayPal. Faltan parámetros necesarios.'
    end
  end
  
  def paypal_cancel
    @payment.update(status: :failed)
    redirect_to course_path(@payment.enrollment.course), alert: 'El pago con PayPal ha sido cancelado.'
  end

  def bank_transfer_instructions
    @bank_details = {
      bank_name: ENV['BANK_NAME'] || 'Banco Nacional',
      account_number: ENV['BANK_ACCOUNT_NUMBER'] || '1234-5678-9012-3456',
      account_name: ENV['BANK_ACCOUNT_NAME'] || 'Cursos en Línea S.A.',
      swift_code: ENV['BANK_SWIFT_CODE'] || 'BNPAFRPPXXX'
    }
  end
  
  def upload_receipt
    # Verificar que el usuario es el propietario del pago
    unless @payment.user == current_user
      redirect_to root_path, alert: 'No estás autorizado para realizar esta acción.'
      return
    end
    
    # Verificar que el pago está pendiente y es por transferencia bancaria
    unless @payment.pending? && @payment.bank_transfer?
      redirect_to course_path(@payment.enrollment.course), alert: 'Este pago no puede ser actualizado.'
      return
    end
    
    # Adjuntar el comprobante al pago
    if params[:receipt].present?
      @payment.receipt.attach(params[:receipt])
      @payment.update(notes: params[:notes]) if params[:notes].present?
      
      # Notificar a los administradores que hay un nuevo comprobante
      # En una implementación real, se enviaría un correo a los administradores
      # AdminMailer.new_receipt_notification(@payment).deliver_later
      
      redirect_to course_path(@payment.enrollment.course), notice: 'Comprobante subido correctamente. Un administrador verificará tu pago pronto.'
    else
      redirect_to bank_transfer_instructions_course_enrollment_payment_path(
        @payment.enrollment.course, 
        @payment.enrollment, 
        @payment
      ), alert: 'Debes seleccionar un archivo para subir.'
    end
  end

  private
  
  def process_stripe_payment
    begin
      # Utilizar el servicio de Stripe para crear la sesión de pago
      stripe_service = StripeService.new(@payment)
      session = stripe_service.create_checkout_session
      
      # Guardar el ID de sesión para referencia futura
      @payment.update(stripe_session_id: session.id)
      
      # Redirigir a la página de pago de Stripe
      redirect_to session.url, allow_other_host: true
    rescue => e
      Rails.logger.error("Error al crear sesión de Stripe: #{e.message}")
      @payment.update(status: :failed)
      flash[:alert] = 'Error al conectar con Stripe. Por favor, inténtalo de nuevo o elige otro método de pago.'
      redirect_to new_course_enrollment_payment_path(@enrollment.course, @enrollment)
    end
  end
  
  def process_paypal_payment
    begin
      # Utilizar el servicio de PayPal para crear la sesión de pago
      paypal_service = PaypalService.new(@payment)
      approval_url = paypal_service.create_payment
      
      # Redirigir a la URL de aprobación de PayPal
      redirect_to approval_url, allow_other_host: true
    rescue => e
      Rails.logger.error("Error al crear pago PayPal: #{e.message}")
      @payment.update(status: :failed)
      flash[:alert] = 'Error al conectar con PayPal. Por favor, inténtalo de nuevo o elige otro método de pago.'
      redirect_to new_course_enrollment_payment_path(@enrollment.course, @enrollment)
    end
  end

  def set_enrollment
    @enrollment = Enrollment.find(params[:enrollment_id])
  end
  
  def set_payment
    @payment = Payment.find(params[:id] || params[:payment_id])
  end

  def payment_params
    params.require(:payment).permit(:payment_method)
  end
  
  def verify_paypal_webhook
    # Verificar la autenticidad del webhook de PayPal
    # Obtener los datos de la notificación IPN
    raw_post = request.raw_post
    
    # Preparar la respuesta para PayPal
    response = "cmd=_notify-validate&#{raw_post}"
    
    # Configurar la conexión HTTP para verificar con PayPal
    uri = URI.parse(ENV['PAYPAL_IPN_VERIFY_URL'] || 'https://ipnpb.paypal.com/cgi-bin/webscr')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    
    # Enviar la solicitud a PayPal
    begin
      http_response = http.post(uri.path, response,
        'Content-Type' => 'application/x-www-form-urlencoded',
        'User-Agent' => 'PayPal IPN Verification'
      )
      
      # Verificar la respuesta
      case http_response.body
      when "VERIFIED"
        Rails.logger.info("PayPal IPN Verified: #{params}")
        return true
      when "INVALID"
        Rails.logger.error("PayPal IPN Invalid: #{params}")
        return false
      else
        Rails.logger.error("PayPal IPN Error: Unexpected response #{http_response.body}")
        return false
      end
    rescue => e
      Rails.logger.error("PayPal IPN Exception: #{e.message}")
      return false
    end
  end
end
