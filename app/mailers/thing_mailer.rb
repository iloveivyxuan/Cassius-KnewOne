#encoding: utf-8
class ThingMailer < BaseMailer
  def encourage_owner(thing, user)
    @thing = thing
    @user = user

    mail(to: @user.email,
         subject: "你在KnewOne上拥有的产品“#{@thing.title}”有何使用体验？")
  end

  def encourage_review_author(user)
    @user = user
    @reviews = user.reviews.recent

    mail(to: @user.email,
         subject: '你在KnewOne上产品评测的最新动态')
  end

  def encourage_thing_author(user)
    @user = user
    @things = user.things.recent

    mail(to: @user.email,
         subject: '你在KnewOne上分享产品的最新动态')
  end
end
