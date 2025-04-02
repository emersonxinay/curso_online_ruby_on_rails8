class AddTimestampsToEnrollments < ActiveRecord::Migration[8.0]
  def change
    add_column :enrollments, :created_at, :datetime, null: false
    add_column :enrollments, :updated_at, :datetime, null: false
    add_reference :enrollments, :user, null: false, foreign_key: true
    add_reference :enrollments, :course, null: false, foreign_key: true
    add_column :enrollments, :price, :decimal, precision: 10, scale: 2, null: false
    add_column :enrollments, :status, :integer, default: 0, null: false
  end
end
