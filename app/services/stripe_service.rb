class StripeService
  def initialize(payment)
    @payment = payment
  end

  def create_checkout_session
    # Crear una sesión de pago con Stripe
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: {
            name: @payment.enrollment.course.title,
            description: @payment.enrollment.course.description.to_plain_text.truncate(500),
            images: [@payment.enrollment.course.cover_image.attached? ? 
                    Rails.application.routes.url_helpers.url_for(@payment.enrollment.course.cover_image) : nil].compact
          },
          unit_amount: (@payment.amount * 100).to_i
        },
        quantity: 1
      }],
      mode: 'payment',
      success_url: payment_success_url(@payment) + "?payment_intent={CHECKOUT_SESSION_ID}",
      cancel_url: payment_cancel_url(@payment),
      metadata: {
        payment_id: @payment.id,
        enrollment_id: @payment.enrollment.id,
        course_id: @payment.enrollment.course.id,
        user_id: @payment.user.id
      },
      customer_email: @payment.user.email
    )

    # Guardar el ID de sesión para referencia futura
    @payment.update(stripe_session_id: session.id)
    session
  end

  def self.handle_webhook(event)
    case event.type
    when 'checkout.session.completed'
      handle_checkout_completed(event)
    end
  end

  def self.handle_checkout_completed(event)
    session = event.data.object
    payment = Payment.find_by(stripe_session_id: session.id)
    
    return unless payment

    payment.transaction_id = session.payment_intent
    payment.mark_as_completed!
    
    PaymentMailer.payment_confirmation(payment).deliver_later
    PaymentCompletedJob.perform_later(payment.id)
  end

  private

  def payment_success_url(payment)
    Rails.application.routes.url_helpers.payment_success_url(payment_id: payment.id)
  end

  def payment_cancel_url(payment)
    Rails.application.routes.url_helpers.payment_cancel_url(payment_id: payment.id)
  end
end
