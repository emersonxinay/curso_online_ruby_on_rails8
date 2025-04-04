class Certificate < ApplicationRecord
  belongs_to :user
  belongs_to :course
  has_one :enrollment, foreign_key: :course_id
  
  validates :user_id, presence: true
  validates :course_id, presence: true
  validates :issued_at, presence: true
  
  before_create :set_issued_at
  
  private
  
  def set_issued_at
    self.issued_at = Time.current
  end
end
