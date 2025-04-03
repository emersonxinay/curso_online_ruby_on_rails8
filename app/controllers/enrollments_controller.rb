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
    # Verificar si el usuario ya está inscrito en el curso
    if current_user.enrolled?(@course)
      redirect_to course_path(@course), alert: 'Ya estás inscrito en este curso.'
      return
    end

    # Verificar si el curso es gratuito
    if @course.price.zero?
      create_free_enrollment
      return
    end

    # Crear la inscripción con estado pendiente
    @enrollment = current_user.enrollments.build(
      course: @course,
      price: @course.price,
      status: :pending
    )

    if @enrollment.save
      # Redirigir a la selección de método de pago
      redirect_to new_course_enrollment_payment_path(@course, @enrollment)
    else
      redirect_to course_path(@course), alert: 'Error al inscribirse en el curso.'
    end
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def create_free_enrollment
    @enrollment = current_user.enrollments.build(
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
