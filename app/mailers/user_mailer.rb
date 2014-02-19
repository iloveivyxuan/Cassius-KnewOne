class UserMailer < BaseMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome.subject
  #
  def welcome(user)
    return false if user.blank? or user.email.blank?
    @user = user
    mail(to: @user.email,
         subject: 'Welcome to Knewone')
  end

  def foo(email)
    mail(to: email,
         subject: 'Test mail sending')
  end
end
