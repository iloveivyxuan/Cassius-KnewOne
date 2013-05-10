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
      content_tag :div, present(review).content, class: "top_review review_content"
    end
  end

  def author
    present(thing.author).as_author
  end

  def photo_url(size)
    thing.photos.first.url(size)
  end

  def photo(size, options={})
    image_tag photo_url(size), options.merge(alt: title)
  end

  def price
    if thing.price.to_i > 0 and can_buy?
      content_tag :small,
      number_to_currency(thing.price, precision: 2, unit: thing.price_unit)
    end
  end

  def shop
    word = "购买"
    icon = "icon-shopping-cart icon-large"

    if can_buy?
      link_to_with_icon word, icon, buy_thing_path(thing), target: '_blank',
      class: "track_event btn btn-success",
      data: {action: "buy", category: "thing", label: title}
    else
      link_to_with_icon word, icon, "#",
      class: "btn disabled popover-toggle",
      data: {
        toggle: "popover",
        placement: "top",
        title: "暂时不能购买",
        content: "抱歉，目前还没有合适的渠道让您购买到此商品，不过，我们会一直追踪此商品的最新动向，一旦您所在的地区可以购买，我们会第一时间提供最靠谱的购买渠道，敬请期待"
      }
    end
  end

  def self_run
    content_tag :div, class: "self_run" do
      link_to_with_icon "#{brand}自营", "icon-trophy", "#",
      class: "popover-toggle",
      data: {
        toggle: "popover",
        placement: "bottom",
        title: "什么是#{brand}自营?",
        content: "为了保证商品的质量，我们会从可靠的供应商处获得一些最受欢迎的产品，通过自己经营的网店进行销售，请大家放心购买"
      }
    end if thing.is_self_run?
  end

  def supplier
    content_tag :div, class: "supplier" do
      link_to_with_icon "申请供货", "icon-truck", "#",
      data: {toggle: "modal", target: "#supplier-modal"}
    end
  end

  def official_site
    if thing.official_site.present?
      link_to_with_icon "", "icon-globe", thing.official_site, target: "_blank", title: "官方信息"
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

  def reviews_count
    content_tag :span, thing.reviews.count, class: "reviews_count"
  end

  def share_content
    user_signed_in? or return
    topic = present(current_user).topic_wrapper(brand)
    %{我在#{topic}发现了一个酷产品, #{title}: #{thing_url(thing)}}
  end

  def packages
    thing.packages.map do |p|
      present p
    end
  end

  def pre
    if thing.is_pre
      content_tag :span, title: "预售产品", class: "pre" do
        content_tag(:i, "", class: "icon-bell-alt")
      end
    end
  end

  def can_buy
    if can_buy?
      content_tag :span, title: "可以购买", class: "can_buy" do
        content_tag :i, "", class: "icon-shopping-cart"
      end
    end
  end

  def limit
    if thing.is_limit
      content_tag :span, title: "限量产品", class: "limit" do
        content_tag(:i, "", class: "icon-trophy")
      end
    end
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
