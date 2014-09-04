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

  def stock(user, thing)
    @user = user
    @thing = thing

    mail(to: user.email,
         subject: "你在「KnewOne 牛玩」上喜欢的产品\"#{thing.title}\"到货了")
  end

  def chosen(email, name)
    attachments.inline['cuptime_qr.jpg'] = File.read(Rails.root.join('app/assets/images/mails/cuptime_qr.jpg'))
    @name = name

    mail(to: email,
         subject: '恭喜您在「KnewOne 牛玩」免费领养「Cuptime」成功！')
  end

  def adopt(email, name)
    attachments.inline['adoption.jpg'] = File.read(Rails.root.join('app/assets/images/mails/adoption.jpg'))
    attachments.inline['mid_autumn_1.jpg'] = File.read(Rails.root.join('app/assets/images/mails/mid_autumn_1.jpg'))
    attachments.inline['mid_autumn_2.jpg'] = File.read(Rails.root.join('app/assets/images/mails/mid_autumn_2.jpg'))
    attachments.inline['ko_wechat_qr.png'] = File.read(Rails.root.join('app/assets/images/mails/ko_wechat_qr.png'))
    @name = name

    mail(to: email,
         subject: '【免费领养】月圆之际，「家」是最明亮的主题',
         edm: true)
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
