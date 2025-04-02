PayPal::SDK.configure(
  mode: ENV['PAYPAL_MODE'],
  client_id: ENV['PAYPAL_CLIENT_ID'],
  client_secret: ENV['PAYPAL_CLIENT_SECRET']
)

PayPal::SDK.logger = Rails.logger
