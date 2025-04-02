class Course < ApplicationRecord
  belongs_to :instructor, class_name: 'User', foreign_key: 'user_id'
  has_many :sections, dependent: :destroy
  has_many :lessons, through: :sections
  has_many :enrollments, dependent: :restrict_with_error
  has_many :enrolled_users, through: :enrollments, source: :user
  has_one_attached :cover_image
  has_rich_text :description

  enum :status, { draft: 0, published: 1 }
  
  validates :title, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :description, presence: true, allow_blank: true

  scope :published, -> { where(status: :published) }
  scope :recent, -> { order(created_at: :desc) }

  def enrolled?(user)
    enrollments.exists?(user: user)
  end

  def progress(user)
    return 0 unless enrolled?(user)
    completed_lessons = user.completed_lessons.where(section: sections).count
    total_lessons = lessons.count
    total_lessons.zero? ? 0 : (completed_lessons.to_f / total_lessons * 100).round
  end
end
