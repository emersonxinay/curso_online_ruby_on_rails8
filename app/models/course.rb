class Course < ApplicationRecord
  belongs_to :instructor, class_name: 'User', foreign_key: 'user_id'
  has_many :sections, dependent: :destroy
  has_many :lessons, through: :sections
  has_many :enrollments, dependent: :restrict_with_error
  has_many :enrolled_users, through: :enrollments, source: :user
  has_many :certificates, dependent: :destroy
  has_one_attached :cover_image
  has_rich_text :description

  enum :status, { draft: 0, published: 1 }
  
  validates :title, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :description, presence: true, allow_blank: true
  validate :has_sections_and_lessons, if: :published?

  scope :published, -> { where(status: :published) }
  scope :recent, -> { order(created_at: :desc) }

  def enrolled?(user)
    enrollments.exists?(user: user)
  end

  def progress(user)
    return 0 unless enrolled?(user)
    
    # Obtener los IDs de las lecciones de este curso
    lesson_ids = Lesson.joins(:section).where(sections: { course_id: id }).pluck(:id)
    
    # Contar las lecciones completadas por el usuario
    completed_lessons = user.completed_lessons.where(lesson_id: lesson_ids).count
    
    # Contar el total de lecciones
    total_lessons = lesson_ids.size
    
    # Calcular el porcentaje
    total_lessons.zero? ? 0 : (completed_lessons.to_f / total_lessons * 100).round
  end
  
  def has_content?
    sections.exists? && lessons.exists?
  end
  
  def completion_percentage
    return 0 if sections.empty?
    
    # Verificar si hay imagen de portada
    cover_image_score = cover_image.attached? ? 20 : 0
    
    # Verificar si hay descripción
    description_score = description.present? && description.to_plain_text.length > 100 ? 20 : 0
    
    # Verificar si hay secciones
    section_score = [sections.count * 10, 20].min
    
    # Verificar si hay lecciones
    lesson_score = [lessons.count * 5, 40].min
    
    # Calcular porcentaje total
    cover_image_score + description_score + section_score + lesson_score
  end
  
  def generate_certificate(user)
    return if certificates.exists?(user: user)
    
    certificates.create!(
      user: user,
      issued_at: Time.current
    )
  end
  
  private
  
  def has_sections_and_lessons
    unless sections.exists?
      errors.add(:base, "El curso debe tener al menos una sección antes de ser publicado")
    end
    
    unless lessons.exists?
      errors.add(:base, "El curso debe tener al menos una lección antes de ser publicado")
    end
  end
end
