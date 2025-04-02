class CreateEnrollments < ActiveRecord::Migration[8.0]
  def change
    create_table :enrollments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.decimal :price, precision: 8, scale: 2
      t.integer :status, default: 0
      t.datetime :completed_at

      t.timestamps
    end

    add_index :enrollments, [:user_id, :course_id], unique: true
  end
end
