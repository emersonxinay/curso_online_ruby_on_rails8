class CoursesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_course, only: [:show, :edit, :update, :destroy, :setup]
  before_action :ensure_instructor!, except: [:index, :show]

  def index
    @courses = Course.published.recent.page(params[:page]).per(12)
  end

  def show
    @enrolled = current_user && current_user.enrollments.active.exists?(course: @course)
    @pending_enrollment = current_user && current_user.enrollments.find_by(course: @course, status: :pending)
    @sections = @course.sections.includes(:lessons).order(position: :asc)
    
    # Si el curso está en borrador, solo el instructor o admin pueden verlo
    if @course.draft? && current_user != @course.instructor && !current_user&.admin?
      redirect_to courses_path, alert: 'Este curso aún no está disponible.'
    end
  end

  def new
    @course = current_user.courses.build
  end

  def create
    @course = current_user.courses.build(course_params)
    if @course.save
      redirect_to setup_course_path(@course), notice: 'El curso ha sido creado exitosamente. Ahora completa el contenido.'
    else
      render :new
    end
  end
  
  def setup
    # Asegurarse de que el usuario sea el instructor del curso
    unless @course.instructor == current_user || current_user.admin?
      redirect_to root_path, alert: 'No estás autorizado para configurar este curso.'
      return
    end
    
    # Obtener las secciones y lecciones del curso
    @sections = @course.sections.includes(:lessons).order(position: :asc)
    
    # Calcular el porcentaje de completitud del curso
    @completion_percentage = @course.completion_percentage
  end

  def edit
    authorize_course_owner
  end

  def update
    authorize_course_owner
    if @course.update(course_params)
      # Si el curso no tiene contenido, redirigir a la página de configuración
      if !@course.has_content? && params[:redirect_to] != 'show'
        redirect_to setup_course_path(@course), notice: 'El curso ha sido actualizado. Ahora completa el contenido.'
      else
        redirect_to @course, notice: 'El curso ha sido actualizado exitosamente.'
      end
    else
      render :edit
    end
  end

  def destroy
    authorize_course_owner
    @course.destroy
    redirect_to courses_url, notice: 'Course was successfully deleted.'
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:title, :description, :price, :status, :cover_image)
  end

  def ensure_instructor!
    unless current_user.instructor_or_admin?
      redirect_to root_path, alert: 'You need to be an instructor to perform this action.'
    end
  end

  def authorize_course_owner
    unless current_user.admin? || @course.instructor == current_user
      redirect_to root_path, alert: 'You are not authorized to perform this action.'
    end
  end
end
