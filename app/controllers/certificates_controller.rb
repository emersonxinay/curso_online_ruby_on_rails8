class CertificatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_certificate, only: [:show, :download]
  before_action :authorize_certificate_owner!, only: [:show, :download]

  def index
    @certificates = current_user.certificates.includes(:course).order(issued_at: :desc)
  end

  def show
    @certificate = @certificate
  end

  def download
    respond_to do |format|
      format.pdf do
        begin
          pdf = CertificateGenerator.generate(@certificate, current_user, @certificate.course)
          
          send_data pdf,
                    filename: "certificado_#{@certificate.course.title.parameterize}.pdf",
                    type: 'application/pdf',
                    disposition: 'inline'
        rescue StandardError => e
          Rails.logger.error "Error generating certificate: #{e.message}"
          redirect_to certificates_path, alert: 'Error al generar el certificado. Por favor, inténtalo de nuevo.'
        end
      end
    end
  end

  private

  def set_certificate
    @certificate = Certificate.includes(:course).find(params[:id])
  end

  def authorize_certificate_owner!
    unless @certificate.user == current_user || current_user.admin?
      redirect_to root_path, alert: 'No estás autorizado para ver este certificado.'
    end
  end
end
