class InvoiceService
  def initialize(payment)
    @payment = payment
    @user = payment.user
    @course = payment.enrollment.course
  end

  def generate
    WickedPdf.new.pdf_from_string(
      render_invoice_template,
      page_size: 'A4',
      margin: { top: 20, bottom: 20, left: 20, right: 20 }
    )
  end

  private

  def render_invoice_template
    ActionController::Base.new.render_to_string(
      template: 'invoices/template',
      layout: 'pdf',
      locals: {
        payment: @payment,
        user: @user,
        course: @course
      }
    )
  end
end
