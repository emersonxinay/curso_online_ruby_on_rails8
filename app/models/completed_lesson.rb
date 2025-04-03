class CompletedLesson < ApplicationRecord
  belongs_to :user
  belongs_to :lesson
  has_one :section, through: :lesson
  has_one :course, through: :section

  validates :user_id, presence: true
  validates :lesson_id, presence: true
  validates_uniqueness_of :lesson_id, scope: :user_id
  
  after_create :check_course_completion
  
  private
  
  def check_course_completion
    # Verificar si el usuario ha completado todas las lecciones del curso
    course = lesson.course
    total_lessons = course.lessons.count
    completed_lessons = user.completed_lessons.joins(lesson: :section)
                            .where(sections: { course_id: course.id }).count
    
    # Si ha completado todas las lecciones, marcar la inscripción como completada
    if total_lessons == completed_lessons
      enrollment = user.enrollments.find_by(course: course)
      enrollment&.update(status: :completed)
    end
  end
end
