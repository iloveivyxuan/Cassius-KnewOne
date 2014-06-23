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

  def guide(email, name)
    attachments.inline['guide.jpg'] = File.read(Rails.root.join('app/assets/images/mails/guide.jpg'))
    @name = name

    mail(to: email,
         subject: 'KnewOne分享功能全新上线，邀请您来体验')
  end

  def mail2(email, name)
    attachments.inline['ryfit.jpg'] = File.read(Rails.root.join('app/assets/images/mails/ryfit.jpg'))
    @name = name

    mail(to: email,
         subject: '来「KnewOne 牛玩」，智能硬件等你来「领养」！')
  end

  def ryfit_to_chosen(email, name)
    attachments.inline['ryfit_qr.gif'] = File.read(Rails.root.join('app/assets/images/mails/ryfit_qr.gif'))
    @name = name

    mail(to: email,
         subject: '恭喜您，在「KnewOne 牛玩」免费领养 RyFit 成功！')
  end

  def ryfit_to_loser(email, name)
    @name = name

    mail(to: email,
         subject: '很遗憾，您未能成功在 「KnewOne 牛玩」领养 RyFit！')
  end

  def ryfit_to_expired(email, name)
    @name = name

    mail(to: email,
         subject: '很遗憾，您未能成功在 「KnewOne 牛玩」领养 RyFit！')
  end

  def stock(user, thing)
    @user = user
    @thing = thing

    mail(to: user.email,
         subject: "你在「KnewOne 牛玩」上喜欢的产品\"#{thing.title}\"到货了")
  end

  def private_message(dialog)
    @dialog = dialog
    @receiver = dialog.user
    @sender = dialog.sender
    @message = dialog.newest_message

    mail(to: @receiver.email,
         subject: '你在「KnewOne 牛玩」上收到了一封私信')
  end

  def recall(user_id, items = {})
    @user = User.find(user_id)
    @items = items
    @items[:activities_count] ||= @user.relate_activities.from_date(30.days.ago).to_date(Date.today).size
    @items[:global_things_count] ||= Thing.recent.size
    @items[:global_reviews_count] ||= Review.recent.size
    @items[:things] ||= @user.things.recent
    @items[:owns] ||= @user.owns.recent
    @items[:reviews] ||= @user.reviews.recent

    mail(to: @user.email,
         subject: 'KnewOne动态')
  end
end
