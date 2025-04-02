class SectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course
  before_action :set_section, only: [:edit, :update, :destroy]
  before_action :authorize_course_owner!

  def create
    @section = @course.sections.build(section_params)
    if @section.save
      redirect_to course_path(@course), notice: 'Section was successfully created.'
    else
      redirect_to course_path(@course), alert: 'Error creating section.'
    end
  end

  def edit
  end

  def update
    if @section.update(section_params)
      redirect_to course_path(@course), notice: 'Section was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @section.destroy
    redirect_to course_path(@course), notice: 'Section was successfully deleted.'
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_section
    @section = @course.sections.find(params[:id])
  end

  def section_params
    params.require(:section).permit(:title, :description, :position)
  end

  def authorize_course_owner!
    unless current_user.admin? || @course.instructor == current_user
      redirect_to root_path, alert: 'You are not authorized to perform this action.'
    end
  end
end
