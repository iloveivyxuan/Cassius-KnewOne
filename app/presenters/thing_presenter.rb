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

    content_tag :small,
                number_to_currency(@p, precision: 2,
                                   unit: thing.price_unit)
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

  def selfrun
    if thing.kinds.any?
      render partial: 'things/cart_form', locals: {thing: thing, tp: self} #if can? :put_in_cart, thing
    end
  end

  alias_method :presell, :selfrun

  def buy
    if thing.shop.present? || thing.self_run?
      send thing.stage if respond_to? thing.stage
    else
      concept
    end
  end

  def buy_modal_trigger_btn
    if user_signed_in?
      link_to_with_icon "购买", "icon-shopping-cart icon-large", '#buy-modal',
                        title: tp.title, class: "btn btn-success track_event", target: "_blank",
                        data: {toggle: 'modal', target: '#buy-modal'}, role: 'btn'
    else
      link_to_with_icon "购买", "icon-shopping-cart icon-large", "#", role: 'btn',
                        class: "btn btn-success track_event", data: {toggle: "modal", target: "#login-modal"}
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
    if thing.stage == :selfrun
      if thing.kinds.size == 0
        :concept
      else
        thing.kinds.map { |kind| [kind.stage, Kind::STAGES.keys.index(kind.stage)] }.sort_by { |i| i[1] }.first[0]
      end
    else
      thing.stage
    end
  end

  def stage_text
    if thing.stage == :selfrun
      if thing.kinds.size == 0
        :concept
      else
        thing.kinds.map { |kind| [kind.stage, Kind::STAGES.keys.index(kind.stage)] }.sort_by { |i| i[1] }.first[0]
      end
    else
      thing.stage
    end
    (Thing::STAGES.merge Kind::STAGES)[stage]
  end
end
