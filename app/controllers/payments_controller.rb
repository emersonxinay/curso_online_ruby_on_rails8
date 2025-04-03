class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_enrollment, except: [:stripe_webhook, :paypal_webhook, :success, :cancel, :paypal_success, :paypal_cancel]
  before_action :set_payment, only: [:success, :cancel, :paypal_success, :paypal_cancel, :bank_transfer_instructions]
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
      payment = Payment.find_by(transaction_id: params[:txn_id])
      if payment && params[:payment_status] == "Completed"
        payment.mark_as_completed!
        PaymentMailer.confirmation(payment).deliver_later
      end
    end
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
      # Aquí iría la lógica para ejecutar el pago con PayPal
      # payment.execute(params[:PayerID])
      @payment.update(transaction_id: params[:paymentId], status: :completed)
      @payment.enrollment.update(status: :active)
      PaymentMailer.confirmation(@payment).deliver_later
      redirect_to course_path(@payment.enrollment.course), notice: 'Pago completado exitosamente. ¡Bienvenido al curso!'
    else
      redirect_to course_path(@payment.enrollment.course), alert: 'Error al procesar el pago con PayPal.'
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

  private
  
  def process_stripe_payment
    # Utilizar el servicio de Stripe para crear la sesión de pago
    stripe_service = StripeService.new(@payment)
    session = stripe_service.create_checkout_session
    
    redirect_to session.url, allow_other_host: true
  end
  
  def process_paypal_payment
    # Aquí iría la lógica para crear un pago con PayPal
    # En una implementación real, se utilizaría la API de PayPal
    
    # Ejemplo simplificado:
    success_url = paypal_success_course_enrollment_payment_url(
      @enrollment.course,
      @enrollment,
      @payment
    )
    
    cancel_url = paypal_cancel_course_enrollment_payment_url(
      @enrollment.course,
      @enrollment,
      @payment
    )
    
    # Redirigir a PayPal (en una implementación real)
    redirect_to "https://www.sandbox.paypal.com/checkoutnow?token=demo_#{@payment.id}", allow_other_host: true
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
    # En una implementación real, aquí se verificaría la autenticidad del webhook de PayPal
    # Ejemplo simplificado para esta implementación
    true
  end
end
