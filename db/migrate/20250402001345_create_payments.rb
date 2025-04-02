class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :enrollment, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :status, default: 0
      t.integer :payment_method
      t.string :transaction_id
      t.datetime :completed_at
      t.json :payment_details

      t.timestamps
    end
    
    add_index :payments, :transaction_id, unique: true
  end
end
