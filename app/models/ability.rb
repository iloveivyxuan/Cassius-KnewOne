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
    elsif user.role? :editor
      signed user
      editor
    else
      signed user
    end
  end

  private

  def signed(user)
    can :read, User

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

    can :readall, Message
    can :read, Message

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

    can :create, PrivateDialog
    can [:read, :destroy], PrivateDialog do |dialog|
      dialog.user == user or dialog.sender == user
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
    can :buy, Thing
    can :comments, Thing
    can :wechat_qr, Thing
  end

  def editor
    can :update, Post
    can :update, Story
    can :edit, Thing
    can :update, Thing
    can :pro_edit, Thing
    can :all, Review
    can :manage, Lottery
    can :manage, Supplier
  end

  def pay_callback
    can :tenpay_notify, Order
    can :alipay_notify, Order
  end
end
