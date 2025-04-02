class CreateSections < ActiveRecord::Migration[8.0]
  def change
    create_table :sections do |t|
      t.string :title
      t.text :description
      t.integer :position
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
