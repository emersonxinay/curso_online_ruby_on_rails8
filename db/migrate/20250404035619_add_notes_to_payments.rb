class AddNotesToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :notes, :text
  end
end
