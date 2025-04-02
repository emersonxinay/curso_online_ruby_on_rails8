class Payment < ApplicationRecord
  belongs_to :enrollment
  belongs_to :user
  
  enum status: { pending: 0, completed: 1, failed: 2, refunded: 3 }
  enum payment_method: { stripe: 0, paypal: 1, bank_transfer: 2 }
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_method, presence: true
  validates :status, presence: true
  
  after_create :generate_invoice
  
  def mark_as_completed!
    update(status: :completed, completed_at: Time.current)
    enrollment.update(status: :completed)
  end
  
  private
  
  def generate_invoice
    InvoiceGenerationJob.perform_later(self)
  end
end
