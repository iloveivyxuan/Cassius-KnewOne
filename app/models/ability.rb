class Ability
  include CanCan::Ability

  def initialize(user)
    basic

    if user.blank?
      pay_callback
    elsif user.role? :admin
      can :manage, :all
    elsif user.role? :sale
      signed user
      editor
      can :manage, Order
      can :send_stock_notification, Thing
      can :manage, AbatementCoupon
      can :manage, ThingRebateCoupon
      can :manage, Supplier
    elsif user.role? :editor
      signed user
      editor
    elsif user.role? :volunteer
      signed user
      can :update, Thing
    else
      signed user
    end
  end

  private

  def signed(user)
    can [:follow, :unfollow], User

    can [:create, :update, :destroy], Story do |story|
      [story.thing.author, story.thing.maker, story.author].include? user
    end

    can :create, Supplier

    can :create, Photo
    can :destroy, Photo do |photo|
      photo.user == user
    end

    can :create, ReviewPhoto
    can :create, Review
    can [:update, :destroy], Review do |review|
      review.author == user
    end
    can :vote, Review do |review|
      !review.voted?(user)
    end
    can :unvote, Review do |review|
      review.voted?(user)
    end

    can :create, Feeling
    can [:update, :destroy], Feeling do |feeling|
      feeling.author == user
    end
    can :vote, Feeling do |feeling|
      !feeling.voted?(user)
    end
    can :unvote, Feeling do |feeling|
      feeling.voted?(user)
    end

    can :create, Comment
    can :destroy, Comment do |comment|
      comment.author == user
    end

    can :create, Thing
    can :update, Thing do |thing|
      thing.author == user or thing.maker == user
    end
    can :destroy, Thing do |thing|
      thing.author == user && thing.feelings_count == 0 && thing.reviews_count == 0
    end
    can :fancy, Thing
    can :own, Thing
    can :group_fancy, Thing
    can :create_by_extractor, Thing
    can :extract_url, Thing
    can :coupon, Thing

    can :share, User
    can :bind, User

    can :manage, CartItem do |cart_item|
      cart_item.user == user
    end

    can :manage, Address

    can :create, Order
    can [:read, :deliver_bill, :tenpay, :alipay, :tenpay_wechat, :cancel, :alipay_callback, :tenpay_callback], Order do |order|
      order.user == user
    end

    can :create, Group
    can :update, Group do |group|
      group.has_admin? user
    end
    can :join, Group
    can :leave, Group do |group|
      group.founder != user
    end
    can :fuzzy, Group
    can :invite, Group do |group|
      group.has_member? user
    end
    can :fancy, Group

    can :create, Topic do |topic|
      topic.group.has_member? user
    end
    can [:update, :destroy], Topic do |topic|
      topic.group.has_admin? user
    end
    can :vote, Topic do |topic|
      !topic.voted?(user)
    end
    can :unvote, Topic do |topic|
      topic.voted?(user)
    end

    can :create, Dialog
    can [:read, :destroy], Dialog do |dialog|
      dialog.user == user
    end
    can :destroy, PrivateMessage do |private_message|
      private_message.dialog.user == user
    end

  end

  def basic
    can :read, Photo
    can :read, Post
    can :read, Comment
    can :read, Group
    can :all, Group
    can :members, Group
    can :fancies, Group
    can :read, Topic
    can :read, Lottery
    can :read, User
    can [:owns, :fancies, :things, :reviews, :feelings,
         :activities, :followings, :followers, :groups, :topics, :profile], User
    can [:buy, :groups, :comments, :wechat_qr, :random, :shop], Thing
  end

  def editor
    can :update, Post
    can :update, Story
    can :edit, Thing
    can :update, Thing
    can :destroy, Thing
    can :batch_update, Thing
    can :batch_edit, Thing
    can :edit, Category
    can :update, Category
    can :pro_edit, Thing
    can :manage, Review
    can :manage, Feeling
    can :manage, Lottery
  end

  def pay_callback
    can :tenpay_notify, Order
    can :alipay_notify, Order
  end
end
