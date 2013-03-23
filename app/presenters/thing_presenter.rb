# -*- coding: utf-8 -*-
class ThingPresenter < ApplicationPresenter
  presents :thing
  delegate :title, :subtitle, :description, :photos, to: :thing

  def full_title
    [title, subtitle].reject(&:blank?).join(' - ')
  end

  def top_review
    review = thing.reviews.where(is_top: true).first
    if review
      ReviewPresenter.new(review, @template).content
    end
  end

  def author
    img = link_to thing.author do
      user_avatar(thing.author, :tiny)
    end
    name = link_to thing.author do
      thing.author.name
    end
    img.concat name
  end

  def price
    if thing.price.to_i > 0 and can_buy?
      content_tag :small,
      number_to_currency(thing.price, precision: 2, unit: thing.price_unit)
    end
  end

  def shop
    link_to_with_icon "购买", "icon-shopping-cart icon-large", buy_thing_path(thing), target: '_blank',
    class: "track_event thing_shop btn btn-success btn-large #{'disabled' unless can_buy?}",
    data: {
      # analystics
      action: "buy",
      category: "thing",
      label: title,
      # popover
      placement: "bottom",
      title: "暂时不能购买",
      content: "抱歉，目前还没有合适的渠道让您购买到此商品，不过，我们会一直追踪此商品的最新动向，一旦您所在的地区可以购买，我们会第一时间提供最靠谱的购买渠道，敬请期待"
    }
  end

  def official_site
    if thing.official_site.present?
      link_to_with_icon "", "icon-info-sign", thing.official_site, target: "_blank", title: "官方信息"
    end
  end

  def fancied?
    user_signed_in? and thing.fancied?(current_user)
  end

  def fanciers_count
    content_tag :span, thing.fanciers.count, class: "fanciers_count"
  end

  def owned?
    user_signed_in? and thing.owned?(current_user)
  end

  def owners_count
    content_tag :span, thing.owners.count, class: "owners_count"
  end

  def owners
    thing.owners.desc(:created_at).limit(10)
  end

  private

  def can_buy?
    if thing.shop.blank?
      false
    elsif thing.is_limit?
      current_user and current_user.is_guest?
    else
      true
    end
  end
end
