# -*- coding: utf-8 -*-
class Ability
  include CanCan::Ability

  def initialize(user)
    cannot :manage, :all

    if user.blank?
      basic
    elsif user.role? :admin
      can :manage, :all
    elsif user.role? :editor
      basic
      signed user
      can :update, Post
      can :pro_edit, Thing
      can :pro_update, Thing
    else
      basic
      signed user
    end
  end

  private

  def signed(user)
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

    can :create, Comment
    can :destroy, Comment do |comment|
      comment.author == user
    end

    can :fancy, Thing
    can :own, Thing
    can :share, User
    can :bind, User

    can :readall, Message
    can :read, Message
  end

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
    can :comments, Thing
    can :wechat_qr, Thing
    can :activate, Guest
    can :limits, Guest
    can :create, Supplier
  end
end
