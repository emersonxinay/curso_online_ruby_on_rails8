class UserMailer < ApplicationMailer
  def account_paused(user)
    @user = user
    mail(
      to: @user.email,
      subject: "Tu cuenta ha sido pausada temporalmente"
    )
  end

  def account_activated(user)
    @user = user
    mail(
      to: @user.email,
      subject: "Tu cuenta ha sido reactivada"
    )
  end
end