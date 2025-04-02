class EnrollmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course

  def create
    if current_user.enrolled?(@course)
      redirect_to course_path(@course), alert: 'Ya estás inscrito en este curso.'
      return
    end

    @enrollment = current_user.enrollments.build(
      course: @course,
      price: @course.price,
      status: :pending
    )

    if @enrollment.save
      payment = @enrollment.build_payment(
        user: current_user,
        amount: @course.price,
        payment_method: :stripe,
        status: :pending
      )

      if payment.save
        session = Stripe::Checkout::Session.create(
          payment_method_types: ['card'],
          line_items: [{
            price_data: {
              currency: 'usd',
              product_data: {
                name: @course.title,
                description: @course.description.to_plain_text
              },
              unit_amount: (@course.price * 100).to_i
            },
            quantity: 1
          }],
          mode: 'payment',
          success_url: payment_success_url(payment_id: payment.id),
          cancel_url: payment_cancel_url(payment_id: payment.id)
        )

        redirect_to session.url, allow_other_host: true
      else
        @enrollment.destroy
        redirect_to course_path(@course), alert: 'Error al procesar el pago.'
      end
    else
      redirect_to course_path(@course), alert: 'Error al inscribirse en el curso.'
    end
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end
end
