class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def after_sign_in_path_for(resource)
    case resource.role
    when 'admin'
      dashboard_admin_path
    when 'instructor'
      dashboard_instructor_path
    else
      dashboard_student_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
