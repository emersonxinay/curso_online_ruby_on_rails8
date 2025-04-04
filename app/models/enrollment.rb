class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course
  has_many :payments, dependent: :restrict_with_error
  has_many :completed_lessons, through: :user
  has_one :certificate, as: :course, foreign_key: :course_id
  
  # Validamos unicidad solo si el estado es activo, permitiendo tener una inscripción pendiente y una activa
  validates :user_id, uniqueness: { scope: [:course_id, :status], message: "ya tiene una inscripción con este estado para este curso" }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  scope :active, -> { where(status: :active) }
  
  enum :status, {
    pending: 0,
    active: 1,
    completed: 2,
    refunded: 3
  }, prefix: true
  
  after_create :set_price_from_course
  after_update :generate_certificate, if: :completed?
  
  def progress
    return 0 if course.lessons.empty?
    
    completed = completed_lessons.where(section: course.sections).count
    total = course.lessons.count
    
    (completed.to_f / total * 100).round
  end
  
  def completed?
    status == 'completed'
  end
  
  def mark_as_completed
    return if completed?
    
    # Verificar si todas las lecciones están completadas
    if course.lessons.count == completed_lessons.where(section: course.sections).count
      update(status: :completed)
      
      # Generar certificado si no existe
      if !user.certificates.exists?(course: course)
        Certificate.create(
          user: user,
          course: course,
          issued_at: Time.current
        )
      end
    end
  end
  
  private
  
  def set_price_from_course
    self.price = course.price
  end
  
  def generate_certificate
    return if certificate.present?
    
    certificate = Certificate.create(
      user: user,
      course: course,
      issued_at: Time.current
    )
    
    certificate.save
  end
end
