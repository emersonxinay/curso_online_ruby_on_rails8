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
    # Crear o encontrar la entrada de lección completada
    completed_lesson = current_user.completed_lessons.find_or_create_by(lesson: @lesson)
    
    # Verificar si el curso está completado
    course_completed = @course.lessons.count == current_user.completed_lessons.where(lesson_id: @course.lessons.pluck(:id)).count
    
    # Si el curso está completado, generar certificado
    if course_completed && !current_user.certificates.exists?(course: @course)
      Certificate.create(user: current_user, course: @course)
      flash[:notice] = '¡Felicidades! Has completado el curso y obtenido tu certificado.'
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
    unless @lesson.is_free || current_user.admin? || 
           @course.instructor == current_user || 
           current_user.enrolled?(@course)
      redirect_to course_path(@course), 
                  alert: 'Necesitas estar inscrito en este curso para ver esta lección.'
    end
  end
end
