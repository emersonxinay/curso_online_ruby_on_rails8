class Admin::PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_payment, only: [:show, :approve, :reject]
  
  def index
    @payments = Payment.includes(:user, enrollment: :course).order(created_at: :desc)
    
    # Filtrar por método de pago si se especifica
    if params[:payment_method].present?
      @payments = @payments.where(payment_method: params[:payment_method])
    end
    
    # Filtrar por estado si se especifica
    if params[:status].present?
      @payments = @payments.where(status: params[:status])
    end
    
    # Paginar resultados
    @payments = @payments.page(params[:page]).per(20)
  end
  
  def show
    # Mostrar detalles del pago
  end
  
  def approve
    if @payment.pending? && @payment.bank_transfer?
      @payment.mark_as_completed!
      @payment.enrollment.update(status: :active)
      
      # Enviar correo de confirmación
      PaymentMailer.confirmation(@payment).deliver_later
      
      redirect_to admin_payments_path, notice: 'Pago aprobado correctamente.'
    else
      redirect_to admin_payments_path, alert: 'Este pago no puede ser aprobado.'
    end
  end
  
  def reject
    if @payment.pending? && @payment.bank_transfer?
      @payment.update(status: :failed)
      
      # Enviar correo de rechazo
      PaymentMailer.rejection(@payment).deliver_later
      
      redirect_to admin_payments_path, notice: 'Pago rechazado correctamente.'
    else
      redirect_to admin_payments_path, alert: 'Este pago no puede ser rechazado.'
    end
  end
  
  private
  
  def set_payment
    @payment = Payment.find(params[:id])
  end
  
  def require_admin
    unless current_user.admin?
      redirect_to root_path, alert: 'No tienes permiso para acceder a esta sección.'
    end
  end
end