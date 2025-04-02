class CompletedLesson < ApplicationRecord
  belongs_to :user
  belongs_to :lesson

  validates :user_id, presence: true
  validates :lesson_id, presence: true
  validates_uniqueness_of :lesson_id, scope: :user_id
end
