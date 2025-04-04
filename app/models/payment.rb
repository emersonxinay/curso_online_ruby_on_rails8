class Payment < ApplicationRecord
  belongs_to :enrollment
  belongs_to :user
  
  # Adjuntar factura y comprobante con Active Storage
  has_one_attached :invoice
  has_one_attached :receipt
  
  enum :status, { pending: 0, completed: 1, failed: 2, refunded: 3 }
  enum :payment_method, { stripe: 0, paypal: 1, bank_transfer: 2 }
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_method, presence: true
  validates :status, presence: true
  
  after_create :generate_invoice
  
  def mark_as_completed!
    update(status: :completed, completed_at: Time.current)
    enrollment.update(status: :active)
  end
  
  private
  
  def generate_invoice
    # Implementación básica del generador de facturas
    # Se puede expandir según los requisitos específicos
    update(invoice_number: "INV-#{Time.current.to_i}-#{id}")
    InvoiceGenerationJob.perform_later(self)
  end
end
