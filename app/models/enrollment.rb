class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course
  
  validates :user_id, uniqueness: { scope: :course_id }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  enum :status, {
    pending: 0,
    completed: 1,
    refunded: 2
  }, prefix: true
end
