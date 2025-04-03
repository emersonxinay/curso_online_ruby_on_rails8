class InvoiceGenerationJob < ApplicationJob
  queue_as :default

  def perform(payment)
    # Obtener datos necesarios para la factura
    @payment = payment
    @enrollment = payment.enrollment
    @course = @enrollment.course
    @student = @enrollment.user
    @instructor = @course.instructor

    # Generar el PDF de la factura usando WickedPDF
    pdf_content = generate_pdf
    
    # Guardar el PDF en el sistema de archivos o en Active Storage
    save_invoice(pdf_content)
    
    # Enviar la factura por correo electrónico
    InvoiceMailer.send_invoice(@payment).deliver_later
  end

  private

  def generate_pdf
    WickedPdf.new.pdf_from_string(
      render_invoice_template,
      page_size: 'A4',
      margin: { top: 15, bottom: 15, left: 15, right: 15 },
      footer: { center: 'Página [page] de [topage]', font_size: 9 },
      encoding: 'UTF-8'
    )
  end

  def render_invoice_template
    # En una implementación real, esto renderizaría una vista de Rails
    # ActionController::Base.new.render_to_string(
    #   template: 'invoices/show',
    #   layout: 'invoice',
    #   locals: { payment: @payment, course: @course, student: @student }
    # )
    
    # Para esta implementación simplificada, generamos HTML básico
    <<-HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>Factura ##{@payment.id}</title>
        <style>
          body { font-family: Arial, sans-serif; }
          .header { text-align: center; margin-bottom: 30px; }
          .invoice-box { max-width: 800px; margin: auto; padding: 30px; border: 1px solid #eee; box-shadow: 0 0 10px rgba(0, 0, 0, .15); }
          .invoice-box table { width: 100%; line-height: inherit; text-align: left; }
          .invoice-box table td { padding: 5px; vertical-align: top; }
          .invoice-box table tr.top table td { padding-bottom: 20px; }
          .invoice-box table tr.heading td { background: #eee; border-bottom: 1px solid #ddd; font-weight: bold; }
          .invoice-box table tr.item td { border-bottom: 1px solid #eee; }
          .invoice-box table tr.total td:nth-child(2) { border-top: 2px solid #eee; font-weight: bold; }
        </style>
      </head>
      <body>
        <div class="invoice-box">
          <div class="header">
            <h1>Factura</h1>
            <p>Número: #{@payment.id}</p>
            <p>Fecha: #{@payment.updated_at.strftime('%d/%m/%Y')}</p>
          </div>
          
          <table cellpadding="0" cellspacing="0">
            <tr class="top">
              <td colspan="2">
                <table>
                  <tr>
                    <td>
                      <strong>Cursos en Línea</strong><br>
                      Dirección de la empresa<br>
                      Ciudad, País
                    </td>
                    <td style="text-align: right;">
                      <strong>Cliente:</strong><br>
                      #{@student.name}<br>
                      #{@student.email}
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
            
            <tr class="heading">
              <td>Concepto</td>
              <td style="text-align: right;">Precio</td>
            </tr>
            
            <tr class="item">
              <td>#{@course.title}</td>
              <td style="text-align: right;">$#{sprintf('%.2f', @payment.amount)}</td>
            </tr>
            
            <tr class="total">
              <td></td>
              <td style="text-align: right;">Total: $#{sprintf('%.2f', @payment.amount)}</td>
            </tr>
          </table>
          
          <div style="margin-top: 50px; font-size: 12px; text-align: center;">
            <p>Gracias por tu compra. Si tienes alguna pregunta, no dudes en contactarnos.</p>
          </div>
        </div>
      </body>
      </html>
    HTML
  end

  def save_invoice(pdf_content)
    # Crear un nombre de archivo único para la factura
    filename = "invoice_#{@payment.id}_#{Time.now.to_i}.pdf"
    
    # En una implementación real, esto guardaría el PDF en Active Storage
    # @payment.invoice.attach(
    #   io: StringIO.new(pdf_content),
    #   filename: filename,
    #   content_type: 'application/pdf'
    # )
    
    # Para esta implementación simplificada, guardamos en el sistema de archivos
    invoice_path = Rails.root.join('storage', 'invoices', filename)
    FileUtils.mkdir_p(File.dirname(invoice_path))
    
    File.open(invoice_path, 'wb') do |file|
      file.write(pdf_content)
    end
    
    # Guardar la ruta del archivo en el registro de pago
    @payment.update(invoice_path: "invoices/#{filename}")
  end
end
