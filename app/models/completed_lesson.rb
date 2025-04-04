class CompletedLesson < ApplicationRecord
  belongs_to :user
  belongs_to :lesson
  has_one :section, through: :lesson
  has_one :course, through: :section
  
  validates :user_id, presence: true
  validates :lesson_id, presence: true
  validates_uniqueness_of :lesson_id, scope: :user_id
  
  validate :user_must_be_enrolled
  validate :lesson_must_be_in_active_course
  
  after_create :check_course_completion
  
  scope :for_enrolled_user, ->(user, course) do
    joins(:lesson => [:section => :course])
      .joins("INNER JOIN enrollments ON enrollments.course_id = courses.id AND enrollments.user_id = #{user.id}")
      .where(enrollments: { status: :active })
  end
  
  private
  
  def user_must_be_enrolled
    enrollment = Enrollment.find_by(user_id: user_id, course_id: course_id)
    return if enrollment&.active?
    
    errors.add(:base, 'El usuario no está inscrito en el curso')
  end
  
  def lesson_must_be_in_active_course
    return if course&.active?
    
    errors.add(:base, 'La lección no pertenece a un curso activo')
  end
  
  def check_course_completion
    enrollment = Enrollment.find_by(user_id: user_id, course_id: course_id)
    return unless enrollment&.active?
    
    total_lessons = course.lessons.count
    completed_lessons = user.completed_lessons.for_enrolled_user(user, course).count
    
    if total_lessons == completed_lessons
      enrollment.mark_as_completed
    end
  end
end
