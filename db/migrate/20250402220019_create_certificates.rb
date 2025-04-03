class CreateCertificates < ActiveRecord::Migration[7.0]
  def change
    create_table :certificates do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.datetime :issued_at

      t.timestamps
    end
    
    add_index :certificates, [:user_id, :course_id], unique: true
  end
end
