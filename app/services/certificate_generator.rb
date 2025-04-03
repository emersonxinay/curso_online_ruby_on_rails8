class CertificateGenerator
  def self.generate(certificate, user, course)
    # Convertir HTML a PDF usando Prawn
    pdf = Prawn::Document.new(page_size: 'LETTER', page_layout: :landscape)
    
    # Usar Helvetica que viene por defecto en Prawn
    pdf.font "Helvetica"
    
    # Agregar contenido centrado
    pdf.move_down 100
    pdf.text "CERTIFICADO DE FINALIZACIÓN", size: 30, style: :bold, align: :center
    
    pdf.move_down 50
    pdf.text "Se certifica que", size: 16, align: :center
    
    pdf.move_down 20
    pdf.text user.name.upcase, size: 24, style: :bold, align: :center
    
    pdf.move_down 20
    pdf.text "ha completado exitosamente el curso", size: 16, align: :center
    
    pdf.move_down 20
    pdf.text course.title, size: 20, style: :bold, align: :center
    
    pdf.move_down 40
    pdf.text "Fecha de emisión: #{I18n.l(certificate.issued_at, format: :long)}", size: 14, align: :center
    
    pdf.move_down 20
    pdf.text "Certificado ID: #{certificate.id}", size: 12, align: :center

    pdf.render
  end

  private

  def self.render_to_string(options = {})
    view = ActionView::Base.new(ActionController::Base.view_paths)
    view.extend(ApplicationHelper)
    view.extend(Rails.application.routes.url_helpers)

    view.class_eval do
      include Rails.application.routes.url_helpers
      include ActionView::Helpers::AssetTagHelper
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::DateHelper

      def protect_against_forgery?
        false
      end

      def controller
        @controller ||= ApplicationController.new
      end
    end

    view.render(options)
  end
end
