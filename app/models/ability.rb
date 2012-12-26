class Ability
  include CanCan::Ability

  def initialize(user)
    if user.blank?
      basic
    else
      can :create, Guide
      can [:update, :destroy], Guide do |guide|
        guide.author == user
      end
      basic
    end
  end

  private

  def basic
    can :read, Guide
    can :read, User
  end
end
