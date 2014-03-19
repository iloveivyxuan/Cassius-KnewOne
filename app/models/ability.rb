# -*- coding: utf-8 -*-
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
    elsif user.role? :editor
      signed user
      editor
    else
      signed user
    end
  end

  private

  def signed(user)
    can [:follow, :unfollow], User

    can :create, Post
    can [:update, :destroy], Post do |post|
      post.author == user
    end

    can [:update, :destroy], Story do |story|
      story.thing.author == user or story.author == user
    end

    can :create, Supplier

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
      group.is_admin? user
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
    can :read, Topic
    can :read, Lottery
    can :read, Investor
    can :read, User
    can [:owns, :fancies, :things, :reviews, :activities, :followings, :followers], User
    can :buy, Thing
    can :comments, Thing
    can :wechat_qr, Thing
    can :random, Thing
  end

  def editor
    can :update, Post
    can :update, Story
    can :edit, Thing
    can :update, Thing
    can :edit, Category
    can :update, Category
    can :pro_edit, Thing
    can :manage, Review
    can :manage, Lottery
    can :manage, Supplier
  end

  def pay_callback
    can :tenpay_notify, Order
    can :alipay_notify, Order
  end
end
