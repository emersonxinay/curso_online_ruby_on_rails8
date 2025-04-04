class CertificatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_certificate, only: [:show, :download]
  before_action :authorize_certificate_owner!, only: [:show, :download]
  before_action :validate_certificate_access, only: [:show, :download]

  def index
    @certificates = current_user.certificates.includes(:course).order(issued_at: :desc)
  end

  def show
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

  def validate_certificate_access
    # Verificar que el usuario tenga una inscripción activa para este curso
    enrollment = current_user.enrollments.active.find_by(course: @certificate.course)
    
    unless enrollment
      redirect_to root_path, alert: 'No puedes acceder a este certificado porque no estás inscrito en el curso.'
      return
    end
    
    # Verificar que la inscripción esté marcada como completada
    unless enrollment.completed?
      redirect_to course_path(@certificate.course), alert: 'No puedes acceder a este certificado porque no has completado el curso.'
    end
  end
end
