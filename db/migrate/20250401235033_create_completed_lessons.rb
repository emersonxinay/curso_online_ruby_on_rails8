class CreateCompletedLessons < ActiveRecord::Migration[8.0]
  def change
    create_table :completed_lessons do |t|
      t.references :user, null: false, foreign_key: true
      t.references :lesson, null: false, foreign_key: true

      t.timestamps
    end

    add_index :completed_lessons, [:user_id, :lesson_id], unique: true
  end
end
