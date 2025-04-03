class InvoiceMailer < ApplicationMailer
  def send_invoice(payment)
    @payment = payment
    @user = payment.user
    @course = payment.enrollment.course
    @enrollment = payment.enrollment

    # Adjuntar la factura si existe
    if payment.invoice_path.present?
      invoice_path = Rails.root.join('storage', payment.invoice_path)
      if File.exist?(invoice_path)
        attachments["factura_#{payment.id}.pdf"] = File.read(invoice_path)
      end
    end

    mail(
      to: @user.email,
      subject: "Factura de tu compra - #{@course.title}"
    )
  end
end
