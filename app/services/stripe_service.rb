class StripeService
  def initialize(payment)
    @payment = payment
  end

  def create_checkout_session
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: {
            name: @payment.enrollment.course.title,
            description: @payment.enrollment.course.description.to_plain_text
          },
          unit_amount: (@payment.amount * 100).to_i
        },
        quantity: 1
      }],
      mode: 'payment',
      success_url: payment_success_url(@payment),
      cancel_url: payment_cancel_url(@payment),
      metadata: {
        payment_id: @payment.id,
        enrollment_id: @payment.enrollment.id
      }
    )

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
