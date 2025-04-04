class LessonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course
  before_action :set_section
  before_action :set_lesson, only: [:show, :edit, :update, :destroy, :complete]
  before_action :authorize_course_owner!, except: [:show, :complete]
  before_action :ensure_enrolled!, only: [:show]

  def show
    # Establecer variables para la navegación entre lecciones
    @sections = @course.sections.includes(:lessons).order(position: :asc)
  end

  def new
    @lesson = @section.lessons.new
  end

  def create
    @lesson = @section.lessons.build(lesson_params)
    
    if @lesson.save
      redirect_to course_path(@course), notice: 'La lección se ha creado correctamente.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @lesson.update(lesson_params)
      redirect_to course_section_lesson_path(@course, @section, @lesson), 
                  notice: 'La lección se ha actualizado correctamente.'
    else
      render :edit
    end
  end

  def destroy
    @lesson.destroy
    redirect_to course_path(@course), notice: 'La lección se ha eliminado correctamente.'
  end

  def complete
    # Verificar si la lección es gratuita o si el usuario está inscrito
    unless @lesson.is_free || current_user.enrollments.active.exists?(course: @course)
      flash[:alert] = 'Debes estar inscrito en el curso para marcar esta lección como completada'
      redirect_to course_path(@course) and return
    end

    # Intentar crear o encontrar la entrada de lección completada
    completed_lesson = current_user.completed_lessons.find_or_create_by(lesson: @lesson)
    
    if completed_lesson.errors.any?
      flash[:alert] = completed_lesson.errors.full_messages.join("<br>").html_safe
      redirect_to course_section_lesson_path(@course, @section, @lesson) and return
    end

    # Verificar si el curso está completado
    course_completed = @course.lessons.count == current_user.completed_lessons.for_enrolled_user(current_user, @course).count
    
    # Si el curso está completado y el usuario tiene una inscripción activa
    if course_completed && current_user.enrollments.active.find_by(course: @course)
      flash[:notice] = '¡Felicidades! Has completado el curso.'
    else
      flash[:notice] = 'Lección marcada como completada.'
    end
    
    # Redireccionar a la siguiente lección si existe
    next_lesson = @section.lessons.where("position > ?", @lesson.position).order(position: :asc).first
    
    if next_lesson
      redirect_to course_section_lesson_path(@course, @section, next_lesson)
    else
      # Buscar la primera lección de la siguiente sección
      next_section = @course.sections.where("position > ?", @section.position).order(position: :asc).first
      
      if next_section && next_section.lessons.any?
        redirect_to course_section_lesson_path(@course, next_section, next_section.lessons.order(position: :asc).first)
      else
        # Si no hay más lecciones, redirigir al curso
        redirect_to course_path(@course)
      end
    end
  end

  def mark_as_completed
    @lesson = Lesson.find(params[:id])
    @course = @lesson.section.course
    
    if current_user.completed_lessons.create(lesson: @lesson)
      # Verificar si el usuario completó todas las lecciones del curso
      all_lessons = @course.lessons.joins(:section).pluck(:id)
      completed = current_user.completed_lessons.where(lesson_id: all_lessons).count
      
      if completed == all_lessons.size
        # Generar certificado si no existe
        @course.generate_certificate(current_user)
      end
      
      redirect_to course_path(@course), notice: 'Lección marcada como completada.'
    else
      redirect_to course_path(@course), alert: 'No se pudo marcar la lección como completada.'
    end
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_section
    @section = @course.sections.find(params[:section_id])
  end

  def set_lesson
    @lesson = @section.lessons.find(params[:id])
  end

  def lesson_params
    params.require(:lesson).permit(:title, :content, :video, :position, :is_free)
  end

  def authorize_course_owner!
    unless current_user.admin? || @course.instructor == current_user
      redirect_to root_path, alert: 'No estás autorizado para realizar esta acción.'
    end
  end

  def ensure_enrolled!
    # Si la lección es gratuita, o el usuario es admin o instructor, permitir acceso
    return true if @lesson.is_free || current_user.admin? || @course.instructor == current_user
    
    # Verificar si el usuario está inscrito
    enrollment = current_user.enrollments.active.find_by(course: @course)
    
    if enrollment.nil?
      # Usuario no inscrito
      redirect_to course_path(@course), 
                  alert: 'Necesitas estar inscrito en este curso para ver esta lección.'
      return
    end
    
    # Verificar si la inscripción está activa (pago completado)
    unless enrollment.status_active?
      # Inscripción pendiente o inactiva
      redirect_to course_path(@course), 
                  alert: 'Tu inscripción está pendiente de pago. Por favor, completa el proceso de pago para acceder al contenido del curso.'
      return
    end
  end
end
