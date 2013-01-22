class Ability
  include CanCan::Ability

  def initialize(user)
    if user.blank?
      basic
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
      basic
    end
  end

  private

  def basic
    can :read, Photo
    can :read, Post
    can :read, User
  end
end
