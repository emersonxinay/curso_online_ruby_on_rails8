module AdminHelper
  # Badges para métodos de pago
  def payment_method_badge_class(method)
    case method.to_sym
    when :stripe
      "px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800"
    when :paypal
      "px-2 py-1 rounded-full text-xs font-medium bg-indigo-100 text-indigo-800"
    when :bank_transfer
      "px-2 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
    else
      "px-2 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
    end
  end
  
  # Badges para estados de pago
  def payment_status_badge_class(status)
    case status.to_sym
    when :pending
      "px-2 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800"
    when :completed
      "px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800"
    when :failed
      "px-2 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800"
    when :refunded
      "px-2 py-1 rounded-full text-xs font-medium bg-purple-100 text-purple-800"
    else
      "px-2 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
    end
  end
  
  # Badges para estados de inscripción
  def enrollment_status_badge_class(status)
    case status.to_sym
    when :pending
      "px-2 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800"
    when :active
      "px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800"
    when :completed
      "px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800"
    when :cancelled
      "px-2 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800"
    else
      "px-2 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
    end
  end
  
  # Badges para roles de usuario
  def user_role_badge_class(role)
    case role.to_sym
    when :student
      "px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800"
    when :instructor
      "px-2 py-1 rounded-full text-xs font-medium bg-purple-100 text-purple-800"
    when :admin
      "px-2 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800"
    else
      "px-2 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
    end
  end
  
  # Badges para estados de usuario
  def user_status_badge_class(status)
    case status.to_sym
    when :active
      "px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800"
    when :paused
      "px-2 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800"
    else
      "px-2 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
    end
  end
end
