class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_enrollment
  
  def new
    @payment = @enrollment.payments.build(
      user: current_user,
      amount: @enrollment.course.price
    )
  end

  def create
    @payment = @enrollment.payments.build(payment_params)
    @payment.user = current_user
    @payment.amount = @enrollment.course.price

    if @payment.save
      case @payment.payment_method
      when 'stripe'
        redirect_to stripe_checkout_path(@payment)
      when 'paypal'
        redirect_to paypal_checkout_path(@payment)
      when 'bank_transfer'
        redirect_to bank_transfer_instructions_path(@payment)
      end
    else
      render :new
    end
  end

  def stripe_webhook
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      return head :bad_request
    end

    StripeService.handle_webhook(event)
    head :ok
  end

  def paypal_webhook
    if verify_paypal_webhook
      payment = Payment.find_by(transaction_id: params[:txn_id])
      if payment && params[:payment_status] == "Completed"
        payment.mark_as_completed!
        PaymentMailer.payment_confirmation(payment).deliver_later
      end
    end
    head :ok
  end

  def success
    @payment = Payment.find(params[:payment_id])
    if @payment.completed?
      redirect_to course_path(@payment.enrollment.course), notice: 'Pago completado exitosamente. ¡Bienvenido al curso!'
    else
      redirect_to course_path(@payment.enrollment.course), alert: 'El estado del pago está pendiente de verificación.'
    end
  end

  def cancel
    @payment = Payment.find(params[:payment_id])
    @payment.update(status: :failed)
    redirect_to course_path(@payment.enrollment.course), alert: 'El pago ha sido cancelado.'
  end

  def bank_transfer_instructions
    @payment = Payment.find(params[:payment_id])
    @bank_details = {
      bank_name: ENV['BANK_NAME'],
      account_number: ENV['BANK_ACCOUNT_NUMBER'],
      account_name: ENV['BANK_ACCOUNT_NAME'],
      swift_code: ENV['BANK_SWIFT_CODE']
    }
  end

  private

  def set_enrollment
    @enrollment = Enrollment.find(params[:enrollment_id])
  end

  def payment_params
    params.require(:payment).permit(:payment_method)
  end
end
