class EnrollmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course, except: [:index]

  def index
    @enrollments = current_user.enrollments.includes(course: [:instructor, :cover_image_attachment]).active.order(created_at: :desc)
    @in_progress_courses = @enrollments.select { |e| e.course.progress(current_user) > 0 && e.course.progress(current_user) < 100 }
    @completed_courses = @enrollments.select { |e| e.course.progress(current_user) == 100 }
    @not_started_courses = @enrollments.select { |e| e.course.progress(current_user) == 0 }
    @certificates = current_user.certificates.includes(:course)
  end

  def create
    # Verificar si el usuario ya tiene una inscripción activa
    if current_user.enrollments.where(course: @course, status: :active).exists?
      redirect_to course_path(@course), alert: 'Ya estás inscrito en este curso.'
      return
    end

    # Verificar si el curso es gratuito
    if @course.price.zero?
      create_free_enrollment
      return
    end

    # Verificar si el usuario ya tiene una inscripción pendiente
    pending_enrollment = current_user.enrollments.find_by(course: @course, status: :pending)
    
    if pending_enrollment
      # Si ya existe una inscripción pendiente, redirigir al pago
      redirect_to new_course_enrollment_payment_path(@course, pending_enrollment), 
                  notice: 'Continúa con el proceso de pago para completar tu inscripción.'
      return
    end

    # Crear la inscripción con estado pendiente
    @enrollment = current_user.enrollments.new(
      course: @course,
      price: @course.price,
      status: :pending
    )

    if @enrollment.save
      # Redirigir a la selección de método de pago
      redirect_to new_course_enrollment_payment_path(@course, @enrollment), 
                  notice: 'Selecciona un método de pago para completar tu inscripción.'
    else
      redirect_to course_path(@course), 
                  alert: "Error al inscribirse en el curso: #{@enrollment.errors.full_messages.join(', ')}"
    end
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def create_free_enrollment
    @enrollment = current_user.enrollments.new(
      course: @course,
      price: 0,
      status: :active
    )

    if @enrollment.save
      redirect_to course_path(@course), notice: 'Te has inscrito exitosamente en este curso gratuito.'
    else
      redirect_to course_path(@course), alert: 'Error al inscribirse en el curso.'
    end
  end
end
