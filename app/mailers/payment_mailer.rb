class PaymentMailer < ApplicationMailer
  def confirmation(payment)
    @payment = payment
    @user = payment.user
    @course = payment.enrollment.course

    attachments["invoice_#{payment.id}.pdf"] = InvoiceService.new(payment).generate

    mail(
      to: @user.email,
      subject: "Payment Confirmation - #{@course.title}"
    )
  end
end
