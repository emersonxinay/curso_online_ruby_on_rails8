class PaypalService
  def initialize(payment)
    @payment = payment
  end

  def create_payment
    begin
      # Crear un objeto de pago de PayPal
      payment = PayPal::SDK::REST::Payment.new({
        intent: "sale",
        payer: {
          payment_method: "paypal"
        },
        transactions: [{
          amount: {
            total: @payment.amount.to_s,
            currency: ENV['PAYPAL_CURRENCY'] || "USD"
          },
          description: "Inscripción al curso: #{@payment.enrollment.course.title}",
          invoice_number: @payment.invoice_number || "INV-#{Time.current.to_i}-#{@payment.id}",
          item_list: {
            items: [{
              name: @payment.enrollment.course.title.truncate(127),
              description: @payment.enrollment.course.description.to_plain_text.truncate(127),
              quantity: "1",
              price: @payment.amount.to_s,
              currency: ENV['PAYPAL_CURRENCY'] || "USD"
            }]
          }
        }],
        redirect_urls: {
          return_url: payment_success_url(@payment),
          cancel_url: payment_cancel_url(@payment)
        },
        note_to_payer: "Gracias por inscribirte en nuestro curso. Si tienes alguna pregunta, contáctanos."
      })

      # Crear el pago en PayPal
      if payment.create
        # Guardar el ID de transacción para referencia futura
        @payment.update(transaction_id: payment.id)
        
        # Obtener la URL de aprobación para redirigir al usuario
        approval_url = payment.links.find { |link| link.rel == 'approval_url' }&.href
        
        if approval_url.present?
          return approval_url
        else
          Rails.logger.error("PayPal Error: No approval_url found in payment response")
          raise "No se pudo obtener la URL de aprobación de PayPal"
        end
      else
        Rails.logger.error("PayPal Error: #{payment.error}")
        raise payment.error.to_s
      end
    rescue => e
      Rails.logger.error("PayPal Exception: #{e.message}\n#{e.backtrace.join("\n")}")
      raise "Error al procesar el pago con PayPal: #{e.message}"
    end
  end
  
  def execute_payment(payment_id, payer_id)
    begin
      payment = PayPal::SDK::REST::Payment.find(payment_id)
      
      if payment.nil?
        Rails.logger.error("PayPal Error: Payment not found with ID #{payment_id}")
        return false
      end
      
      if payment.execute(payer_id: payer_id)
        # Verificar que el pago se completó correctamente
        if payment.state == 'approved'
          return true
        else
          Rails.logger.error("PayPal Error: Payment executed but not approved. State: #{payment.state}")
          return false
        end
      else
        Rails.logger.error("PayPal Error: #{payment.error}")
        return false
      end
    rescue => e
      Rails.logger.error("PayPal Exception: #{e.message}\n#{e.backtrace.join("\n")}")
      return false
    end
  end

  private

  def payment_success_url(payment)
    Rails.application.routes.url_helpers.paypal_success_course_enrollment_payment_url(
      @payment.enrollment.course,
      @payment.enrollment,
      @payment,
      host: ENV['APP_URL'] || 'localhost:3000'
    )
  end

  def payment_cancel_url(payment)
    Rails.application.routes.url_helpers.paypal_cancel_course_enrollment_payment_url(
      @payment.enrollment.course,
      @payment.enrollment,
      @payment,
      host: ENV['APP_URL'] || 'localhost:3000'
    )
  end
end
