class CertificatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_certificate, only: [:show, :download]

  def index
    @certificates = current_user.certificates.includes(:course).order(issued_at: :desc)
  end

  def show
  end

  def download
    respond_to do |format|
      format.pdf do
        render pdf: "certificado_#{@certificate.course.title.parameterize}",
               template: "certificates/certificate_pdf",
               layout: "pdf",
               page_size: "Letter",
               orientation: "Landscape",
               title: "Certificado - #{@certificate.course.title}"
      end
    end
  end

  private

  def set_certificate
    @certificate = Certificate.find(params[:id])
    authorize_certificate_owner!
  end

  def authorize_certificate_owner!
    unless current_user == @certificate.user || current_user.admin?
      redirect_to root_path, alert: "No estás autorizado para ver este certificado."
    end
  end
end
