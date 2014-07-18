class ThingMailer < BaseMailer
  def preorder(order, thing, user)
    @thing = thing
    @order = order
    @user = user

    mail(to: user.email,
         subject: "致首批预购用户,\"#{@thing.title}\" 可以购买了！")
  end
end
