class Course < ApplicationRecord
  belongs_to :user
  enum :status, {draft: 0, published:1}
  validates :title, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: {greater_than_or_equal_to: 0}
end
