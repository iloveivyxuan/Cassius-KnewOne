#encoding: utf-8
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
         subject: 'Welcome to KnewOne')
  end

  def award(reward_id)
    @reward = Reward.find(reward_id)
    @user = @reward.user
    return false if @user.email.blank?

    template = case @reward.coupon.class
                 when AbatementCoupon then
                   'award_abatement'
                 when ThingRebateCoupon then
                   'award_thing_rebate'
               end

    mail(to: @user.email,
         subject: '感谢你在KnewOne上的分享！',
         template_name: template)
  end

  def foo(user)
    attachments.inline['guide.jpg'] = File.read(Rails.root.join('app/assets/images/mails/guide.jpg'))

    @user = user
    mail(to: @user.email,
         subject: 'KnewOne分享功能全新上线，邀请您来体验')
  end

  def guide(email, name)
    attachments.inline['guide.jpg'] = File.read(Rails.root.join('app/assets/images/mails/guide.jpg'))
    @name = name

    mail(to: email,
         subject: 'KnewOne分享功能全新上线，邀请您来体验')
  end
end
