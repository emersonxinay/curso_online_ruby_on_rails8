class Lesson < ApplicationRecord
  belongs_to :section
  has_one :course, through: :section
  has_rich_text :content
  has_one_attached :video
  
  validates :title, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
  
  default_scope { order(position: :asc) }
end
