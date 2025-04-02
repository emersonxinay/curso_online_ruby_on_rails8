class PaymentCompletedJob < ApplicationJob
  queue_as :default

  def perform(payment_id)
    payment = Payment.find(payment_id)
    return unless payment.completed?

    # Enviar email de confirmación
    PaymentMailer.confirmation(payment).deliver_later

    # Generar factura
    InvoiceGenerationJob.perform_later(payment)

    # Actualizar inscripción
    payment.enrollment.update(status: :active)

    # Notificar al instructor
    NotificationService.new(payment).notify_instructor
  end
end
