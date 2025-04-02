class Section < ApplicationRecord
  belongs_to :course
  has_many :lessons, dependent: :destroy
  
  validates :title, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
  
  default_scope { order(position: :asc) }
end
