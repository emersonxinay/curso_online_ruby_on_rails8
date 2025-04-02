class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_instructor!, only: [:instructor]
  before_action :ensure_admin!, only: [:admin]

  def student
    @enrolled_courses = current_user.enrolled_courses.includes(:instructor)
    @completed_lessons = current_user.completed_lessons.includes(lesson: { section: :course })
  end

  def instructor
    @courses = current_user.courses.includes(:sections)
    @total_students = current_user.courses.joins(:enrollments).count
    @total_earnings = current_user.courses.joins(:enrollments).sum('enrollments.price')
  end

  def admin
    @total_users = User.count
    @total_courses = Course.count
    @total_enrollments = Enrollment.count
    @recent_enrollments = Enrollment.includes(:user, :course).order(created_at: :desc).limit(10)
  end

  private

  def ensure_instructor!
    unless current_user.instructor_or_admin?
      redirect_to root_path, alert: 'You need to be an instructor to access this page.'
    end
  end

  def ensure_admin!
    unless current_user.admin?
      redirect_to root_path, alert: 'You need to be an admin to access this page.'
    end
  end
end
