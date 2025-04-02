class CreateLessons < ActiveRecord::Migration[8.0]
  def change
    create_table :lessons do |t|
      t.string :title
      t.integer :position
      t.references :section, null: false, foreign_key: true
      t.boolean :is_free, default: false

      t.timestamps
    end
  end
end
