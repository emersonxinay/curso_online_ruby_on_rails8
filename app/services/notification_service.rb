class NotificationService
  def initialize(payment)
    @payment = payment
    @enrollment = payment.enrollment
    @course = @enrollment.course
    @student = @enrollment.user
    @instructor = @course.instructor
  end

  def notify_instructor
    # En una aplicación real, esto podría enviar una notificación en tiempo real
    # a través de ActionCable o enviar un correo electrónico
    InstructorMailer.new_enrollment(@instructor, @course, @student, @payment).deliver_later
    
    # También podríamos crear una notificación en la base de datos
    create_notification(
      recipient: @instructor,
      action: "new_enrollment",
      notifiable: @enrollment,
      message: "#{@student.name} se ha inscrito en tu curso '#{@course.title}'."
    )
  end

  def notify_student(message)
    create_notification(
      recipient: @student,
      action: "course_update",
      notifiable: @course,
      message: message
    )
  end

  private

  def create_notification(attributes)
    # Este método simula la creación de una notificación en la base de datos
    # En una aplicación real, aquí se crearía un registro en la tabla de notificaciones
    Rails.logger.info "Notification created: #{attributes.inspect}"
    
    # Si se implementa un sistema de notificaciones real, se podría descomentar este código
    # Notification.create(attributes)
  end
end
