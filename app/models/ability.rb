# -*- coding: utf-8 -*-
class Ability
  include CanCan::Ability

  def initialize(user)
    cannot :manage, :all

    if user.blank?
      basic
      pay_callback
    elsif user.role? :admin
      can :manage, :all
    elsif user.role? :editor
      basic
      signed user
      can :update, Post
      can :update, Story
      can :update, Feature
      can :pro_edit, Thing
      can :pro_update, Thing
      can :update, Lottery
      can :manage, Supplier
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

    can [:update, :destroy], Story do |story|
      story.thing.author == user or story.author == user
    end

    can [:update, :destroy], Feature do |feature|
      feature.thing.author == user or feature.author == user
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

    can :manage, CartItem do |cart_item|
      cart_item.user == user
    end

    can :manage, Address

    can :create, Order
    can [:read, :tenpay, :cancel], Order do |order|
      order.user == user
    end
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
    can :comments, Thing
    can :wechat_qr, Thing
    can :create, Supplier
  end

  def pay_callback
    can :tenpay_notify, Order
    can :alipay_notify, Order
  end
end
