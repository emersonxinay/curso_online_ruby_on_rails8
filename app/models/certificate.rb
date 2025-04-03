class Certificate < ApplicationRecord
  belongs_to :user
  belongs_to :course
  
  before_create :set_issued_at
  
  private
  
  def set_issued_at
    self.issued_at = Time.current
  end
end
