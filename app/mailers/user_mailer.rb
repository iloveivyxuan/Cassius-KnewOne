class UserMailer < BaseMailer
  skip_before_action :set_logo, only: :newspaper

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
    attachments.inline['chosen_qr.jpg'] = File.read(Rails.root.join('app/assets/images/mails/chosen_qr.jpg'))
    @name = name

    mail(to: email,
         subject: '恭喜你在「KnewOne 牛玩」免费领养「Cuptime」成功！')
  end

  def exchange(email, name)
    attachments.inline['exchange_qr.jpg'] = File.read(Rails.root.join('app/assets/images/mails/exchange_qr.jpg'))
    @name = name

    mail(to: email,
         subject: '恭喜你在「KnewOne 牛玩」活跃点兑换「质造—上下杯」成功！')
  end

  def adopt(email, name)
    attachments.inline['adoption.jpg'] = File.read(Rails.root.join('app/assets/images/mails/adoption.jpg'))
    @name = name

    mail(to: email,
         subject: '【免费领养】糖护士手机血糖仪，为重阳贺',
         edm: true)
  end

  def announcement(email, name)
    @name = name

    mail(to: email,
         subject: 'KnewOne商店国庆放假安排')
  end

  def private_message(dialog)
    @dialog = dialog
    @receiver = dialog.user
    @sender = dialog.sender
    @message = dialog.newest_message

    mail(to: @receiver.email,
         subject: '你在「KnewOne 牛玩」上收到了一封私信')
  end

  def newspaper(user_id, date_str = Date.today.to_s, items = {})
    attachments.inline['bigimage.jpg'] = File.read(Rails.root.join('app/assets/images/mails/bigimage.jpg'))
    attachments.inline['footer.png'] = File.read(Rails.root.join('app/assets/images/mails/footer.png'))

    attachments.inline['special.jpg'] = File.read(Rails.root.join('app/assets/images/mails/special.jpg'))
    attachments.inline['feature.jpg'] = File.read(Rails.root.join('app/assets/images/mails/feature.jpg'))

    @date = Date.parse(date_str)
    @from_date = @date - 7.days
    @user = User.find(user_id)
    @items = items

    friends_things_ids = @user
                           .related_activities(%i(new_thing))
                           .from_date(@from_date)
                           .to_date(@date)
                           .map(&:reference_union)
                           .group_by { |e| e }
                           .values
                           .sort_by! { |e| e.size }
                           .reverse![0..5]
                           .map! {|e| e[0].gsub 'Thing_', ''}

    @items[:friends_things] ||= Thing.where(:id.in => friends_things_ids).to_a
    @items[:friends_things_count] ||= @items[:friends_things].size

    @items[:hot_things] ||= Thing.from_date(@from_date).to_date(@date).hot.limit(6).to_a
    @items[:hot_things_count] ||= 6

    mail(to: @user.email,
         reply_to: 'advice@knewone.com',
         subject: "KnewOne用户周报（#{@from_date.strftime('%Y.%m.%d')} ~ #{@date.strftime('%Y.%m.%d')}）",
         edm: true) do |format|
      format.html { render layout: 'newspaper' }
    end
  end
end
