class InstructorMailer < ApplicationMailer
  def new_enrollment(instructor, course, student, payment)
    @instructor = instructor
    @course = course
    @student = student
    @payment = payment
    @enrollment = payment.enrollment

    mail(
      to: @instructor.email,
      subject: "Nuevo estudiante inscrito en #{@course.title}"
    )
  end

  def course_update(course)
    @course = course
    @instructor = course.instructor

    mail(
      to: @instructor.email,
      subject: "Tu curso ha sido actualizado: #{@course.title}"
    )
  end
end
