class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course
  has_many :payments, dependent: :restrict_with_error
  has_many :completed_lessons, through: :user
  
  validates :user_id, uniqueness: { scope: :course_id }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  scope :active, -> { where(status: :active) }
  
  enum :status, {
    pending: 0,
    active: 1,
    completed: 2,
    refunded: 3
  }, prefix: true
  
  after_create :set_price_from_course
  
  def progress
    return 0 if course.lessons.empty?
    
    completed = completed_lessons.where(section: course.sections).count
    total = course.lessons.count
    
    (completed.to_f / total * 100).round
  end
  
  def completed?
    progress == 100
  end
  
  private
  
  def set_price_from_course
    update(price: course.price) if price.nil? || price.zero?
  end
end
