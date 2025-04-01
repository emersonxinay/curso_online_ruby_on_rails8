class CoursesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_instructor, only: [:new, :create, :edit, :update]
  def new
    @course=Course.new
  end

  def create
    @course = current_user.courses.new(course_params)
    if @course.save
      redirect_to root_path, notice: 'Curso creado exitosamente'
    else
      render :new
    end
  end

  def edit
    @course = current_user.courses.find(params[:id])
  end

  def update
    @course = current_user.courses.find(params[:id])
    if @course.update(course_params)
      redirect_to root_path, notice: 'Curso actualizado exitosamente'
    else
      render :edit
    end
  end
  private
  def course_params
    params.require(:course).permit(:title, :description, :price, :status)
  end
  def check_instructor
    redirect_to root_path, alert: 'No tienes permiso para acceder a esta sección' unless current_user.instructor?
  end
end
