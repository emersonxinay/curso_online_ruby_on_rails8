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
  
  def rejection(payment)
    @payment = payment
    @user = payment.user
    @course = payment.enrollment.course
    
    mail(
      to: @user.email,
      subject: "Pago Rechazado - #{@course.title}"
    )
  end
end
