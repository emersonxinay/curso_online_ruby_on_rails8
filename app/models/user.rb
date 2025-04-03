class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :courses, dependent: :restrict_with_error
  has_many :enrollments, dependent: :destroy
  has_many :enrolled_courses, through: :enrollments, source: :course
  has_many :completed_lessons, dependent: :destroy
  has_many :certificates, dependent: :destroy
  has_one_attached :avatar

  enum :role, { student: 0, instructor: 1, admin: 2 }

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: true

  def instructor_or_admin?
    instructor? || admin?
  end

  def avatar_url
    avatar.attached? ? avatar.url : nil
  end

  def enrolled?(course)
    enrollments.exists?(course: course)
  end
end
