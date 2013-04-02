class Ability
  include CanCan::Ability

  def initialize(user)
    if user.blank?
      basic
    elsif user.admin?
      can :manage, :all
    else
      can :create, Post
      can [:update, :destroy], Post do |post|
        post.author == user
      end

      can :create, Photo
      can :destroy, Photo do |photo|
        photo.user == user
      end

      can :create, ReviewPhoto
      can :vote, Review
      can :digg, Link

      can :create, Comment
      can :destroy, Comment do |comment|
        comment.author == user
      end

      can :fancy, Thing
      can :own, Thing
      can :share, User

      can :readall, Message
      can :read, Message

      basic
    end
  end

  private

  def basic
    can :read, Photo
    can :read, Post
    can :read, User
    can :read, Comment
    can :read, Group
    can :read, Topic
    can :read, Lottery
    can :buy,  Thing
    can :buy_package, Thing
    can :activate, Guest
    can :limits, Guest
    can :create, Supplier
  end
end
