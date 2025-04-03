class AddInvoiceNumberToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :invoice_number, :string
  end
end
