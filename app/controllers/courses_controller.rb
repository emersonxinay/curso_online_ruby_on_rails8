class CoursesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_course, only: [:show, :edit, :update, :destroy]
  before_action :ensure_instructor!, except: [:index, :show]

  def index
    @courses = Course.published.recent.page(params[:page]).per(12)
  end

  def show
    @sections = @course.sections.includes(:lessons)
    @enrolled = current_user&.enrolled?(@course)
  end

  def new
    @course = current_user.courses.build
  end

  def create
    @course = current_user.courses.build(course_params)
    if @course.save
      redirect_to @course, notice: 'Course was successfully created.'
    else
      render :new
    end
  end

  def edit
    authorize_course_owner
  end

  def update
    authorize_course_owner
    if @course.update(course_params)
      redirect_to @course, notice: 'Course was successfully updated.'
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
