class PaypalService
  def initialize(payment)
    @payment = payment
  end

  def create_payment
    payment = PayPal::SDK::REST::Payment.new({
      intent: "sale",
      payer: {
        payment_method: "paypal"
      },
      transactions: [{
        amount: {
          total: @payment.amount.to_s,
          currency: "USD"
        },
        description: "Enrollment for #{@payment.enrollment.course.title}"
      }],
      redirect_urls: {
        return_url: payment_success_url(@payment),
        cancel_url: payment_cancel_url(@payment)
      }
    })

    if payment.create
      @payment.update(transaction_id: payment.id)
      payment.links.find { |link| link.rel == 'approval_url' }.href
    else
      raise payment.error.to_s
    end
  end

  private

  def payment_success_url(payment)
    "#{ENV['APP_URL']}/payments/#{payment.id}/paypal/success"
  end

  def payment_cancel_url(payment)
    "#{ENV['APP_URL']}/payments/#{payment.id}/paypal/cancel"
  end
end
