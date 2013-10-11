# -*- coding: utf-8 -*-
class ThingPresenter < PostPresenter
  presents :thing
  delegate :title, :subtitle, :photos, :self_run?, :stage_end_at, to: :thing

  def full_title
    [title, subtitle].reject(&:blank?).join(' - ')
  end

  def photo_url(size)
    thing.cover.url(size)
  end

  def photo(size, options={})
    image_tag photo_url(size), options.merge(alt: title)
  end

  def content
    content_tag :div, class: "post_content" do
      sanitize(raw thing.content)
    end if thing.content.present?
  end

  def price
    @p ||= if thing.kinds.size > 0
             thing.kinds.map(&:price).min
           elsif thing.price.present?
             thing.price
           end

    if @p.to_i > 0
      content_tag :small,
      number_to_currency(@p, precision: 2,
                         unit: thing.price_unit)
    end
  end

  def concept
    link_to_with_icon "研发中", "icon-wrench icon-large", "#",
                      title: "概念产品", class: "btn disabled popover-toggle",
                      data: {
                          toggle: "popover",
                          placement: "bottom",
                          content: "由于产品还在研发之中，目前还没有合适的渠道让您购买到此商品，不过，我们会一直追踪此商品的最新动向，一旦您所在的地区可以购买，我们会第一时间提供最靠谱的购买渠道，敬请期待"
                      }
  end

  def domestic
    link_to_with_icon "网购", "icon-location-arrow icon-large", buy_thing_path(thing),
                      title: title, class: "btn btn-info track_event", target: "_blank",
                      data: {
                          action: "buy",
                          category: "domestic",
                          label: title
                      }
  end

  def abroad
    link_to_with_icon "海淘", "icon-plane icon-large", buy_thing_path(thing),
                      title: title, class: "btn btn-info track_event", target: "_blank",
                      data: {
                          action: "buy",
                          category: "abroad",
                          label: title
                      }
  end

  def presell
    link_to_with_icon "预购", "icon-phone icon-large", buy_thing_path(thing),
    title: title, class: "btn btn-warning track_event", target: "_blank",
    data: {
      action: "buy",
      category: "presell",
      label: title
    }
  end

  def ship
    link_to_with_icon "即将到货", "icon-anchor icon-large", "#",
    title: "断货产品", class: "btn btn-success disabled popover-toggle",
    data: {
      toggle: "popover",
      placement: "bottom",
      content: "十分抱歉，我们当前没有此产品的库存，不过，一旦新一批产品到货，我们将会通知每位喜欢此产品的用户"
    }
  end

  def stock
    link_to_with_icon "购买", "icon-shopping-cart icon-large", buy_thing_path(thing),
    title: title, class: "btn btn-success track_event", target: "_blank",
    data: {
      action: "buy",
      category: "stock",
      label: title
    }
  end

  def exclusive
    link_to_with_icon "限量", "icon-credit-card icon-large", "#",
    title: "限量产品", class: "btn btn-inverse disabled popover-toggle",
    data: {
      toggle: "popover",
      placement: "bottom",
      content: "此产品数量非常有限，因此我们只提供给少数最狂热的爱好者，敬请谅解"
    }
  end

  def dsell
    if !alpha_pay?
      stock
    elsif !thing.kinds.any?
      stock
    else
      item = CartItem.new thing: thing
      render partial: 'cart_items/new', locals: {cart_item: item}
    end
  end

  def buy
    if respond_to? thing.stage
      send thing.stage
    else
      concept
    end
  end

  def official_site
    if thing.official_site.present?
      link_to_with_icon "", "icon-globe", thing.official_site, target: "_blank", title: "官方信息"
    end
  end

  def fancy_path
    fancy_thing_path(thing)
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
    show_count thing.reviews.count
  end

  def updates_count
    show_count thing.updates.count
  end

  def comments_count
    show_count thing.comments.count
  end

  def share_content
    user_signed_in? or return
    topic = present(current_user).topic_wrapper(brand)
    if current_user == thing.author
      "我在#{topic}上分享了一个酷产品, #{title}: #{thing_url(thing, :refer => 'weibo')}"
    else
      str = "我在#{topic}发现了一个酷产品, #{title}: #{thing_url(thing, :refer => 'weibo')}"
      if current_user.current_auth && current_user != thing.author
        if current_user.equal_auth_provider?(thing.author)
          str += " (感谢 @#{thing.author.current_auth.nickname} 分享)"
        elsif thing.author.current_auth
          str += " (感谢 #{thing.author.current_auth.nickname} from #{thing.author.current_auth.provider} 分享)"
        end
      end
      str
    end
  end

  def reviews(limit)
    thing.reviews.limit(limit)
  end

  def stage
    if thing.stage == :dsell
      if thing.kinds.size == 0
        :concept
      else
        Kind::STAGES.keys.each do |s|
          return s if thing.kinds.map(&:stage).include?(s)
        end
      end
    else
      thing.stage
    end
  end

  def stage_text
    (Thing::STAGES.merge Kind::STAGES)[stage]
  end
end
