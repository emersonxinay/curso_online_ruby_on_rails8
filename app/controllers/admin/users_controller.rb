class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_user, only: [:show, :pause, :activate]
  
  def index
    @users = User.all.order(created_at: :desc)
    
    # Filtrar por rol si se especifica
    if params[:role].present?
      @users = @users.where(role: params[:role])
    end
    
    # Filtrar por estado si se especifica
    if params[:status].present?
      @users = @users.where(status: params[:status])
    end
    
    # Paginar resultados
    @users = @users.page(params[:page]).per(20)
  end
  
  def show
    # Mostrar detalles del usuario
    @enrollments = @user.enrollments.includes(:course).order(created_at: :desc)
    @payments = @user.payments.order(created_at: :desc)
  end
  
  def pause
    if @user.active?
      @user.update(status: :paused)
      
      # Enviar correo de notificación
      UserMailer.account_paused(@user).deliver_later
      
      redirect_to admin_users_path, notice: 'Usuario pausado correctamente.'
    else
      redirect_to admin_users_path, alert: 'Este usuario no puede ser pausado.'
    end
  end
  
  def activate
    if @user.paused?
      @user.update(status: :active)
      
      # Enviar correo de notificación
      UserMailer.account_activated(@user).deliver_later
      
      redirect_to admin_users_path, notice: 'Usuario activado correctamente.'
    else
      redirect_to admin_users_path, alert: 'Este usuario no puede ser activado.'
    end
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def require_admin
    unless current_user.admin?
      redirect_to root_path, alert: 'No tienes permiso para acceder a esta sección.'
    end
  end
end