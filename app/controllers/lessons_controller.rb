class LessonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_section
  before_action :set_lesson, only: [:show, :edit, :update, :destroy, :complete]
  before_action :authorize_course_owner!, except: [:show, :complete]
  before_action :ensure_enrolled!, only: [:show]

  def show
  end

  def create
    @lesson = @section.lessons.build(lesson_params)
    if @lesson.save
      redirect_to course_path(@section.course), notice: 'Lesson was successfully created.'
    else
      redirect_to course_path(@section.course), alert: 'Error creating lesson.'
    end
  end

  def edit
  end

  def update
    if @lesson.update(lesson_params)
      redirect_to course_path(@section.course), notice: 'Lesson was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @lesson.destroy
    redirect_to course_path(@section.course), notice: 'Lesson was successfully deleted.'
  end

  def complete
    current_user.completed_lessons.find_or_create_by(lesson: @lesson)
    redirect_back(fallback_location: course_path(@section.course), notice: 'Lesson marked as completed.')
  end

  private

  def set_section
    @section = Section.find(params[:section_id])
  end

  def set_lesson
    @lesson = @section.lessons.find(params[:id])
  end

  def lesson_params
    params.require(:lesson).permit(:title, :content, :video, :position, :is_free)
  end

  def authorize_course_owner!
    unless current_user.admin? || @section.course.instructor == current_user
      redirect_to root_path, alert: 'You are not authorized to perform this action.'
    end
  end

  def ensure_enrolled!
    unless @lesson.is_free || current_user.admin? || 
           @section.course.instructor == current_user || 
           current_user.enrolled?(@section.course)
      redirect_to course_path(@section.course), 
                  alert: 'You need to be enrolled in this course to view this lesson.'
    end
  end
end
