# -*- coding: utf-8 -*-
class ThingPresenter < PostPresenter
  presents :thing
  delegate :title, :subtitle, :photos, :self_run?, to: :thing

  def path
    thing_path(thing)
  end

  def full_title
    [title, subtitle].reject(&:blank?).join(' - ')
  end

  def photo_url(size)
    thing.cover.url(size)
  end

  def photo(size, options={})
    image_tag photo_url(size), options.merge(alt: title)
  end

  def photo_lazy(size, options={})
    tag "img", options.merge(class: 'lazy', alt: title, data:{original: photo_url(size)})
  end

  def content
    content_tag :div, class: "post_content" do
      sanitize(raw thing.content)
    end if thing.content.present?
  end

  def price
    kinds_price = thing.valid_kinds.map(&:price).uniq
    p = if kinds_price.present?
          kinds_price.min
        elsif thing.price.present?
          thing.price
        end

    if p.to_i > 0
      p_text = price_format p, thing.price_unit
      p_text << " 起" if kinds_price.size > 1
      content_tag :span, p_text
    end
  end

  def content_for_price
    price_text = price
    if price_text.present?
      content_tag :div, price_text, class: "price", id: "price"
    end
  end

  def shopping_desc
    return if thing.shopping_desc.blank?
    summary = strip_tags(thing.shopping_desc).truncate(48).html_safe
    render partial: 'things/shopping_desc',
    locals: {title: title, summary: summary, details: thing.shopping_desc.html_safe}
  end

  def concept
  end

  def domestic
    return concept unless thing.shop.present?
    link_to_with_icon "网购", "fa fa-location-arrow fa-lg", buy_thing_path(thing),
                      title: title, class: "btn btn-info buy_button track_event", target: "_blank", rel: '_nofollow',
                      data: {
                          action: "buy",
                          category: "domestic",
                          label: title
                      }
  end

  def abroad
    return concept unless thing.shop.present?
    link_to_with_icon "海淘", "fa fa-plane fa-lg", buy_thing_path(thing),
                      title: title, class: "btn btn-info buy_button track_event", target: "_blank", rel: '_nofollow',
                      data: {
                          action: "buy",
                          category: "abroad",
                          label: title
                      }
  end

  def invest
    dsell
  end

  def dsell
    if thing.valid_kinds.blank?
      concept
    else
      render partial: 'cart_items/new', locals: {tp: self}
    end
  end

  def buy
    if respond_to? thing.stage
      send thing.stage
    else
      concept
    end
  end

  def content_for_buy
    buy_text = buy
    if buy_text.present?
      content_tag :div, buy_text, class: "buy"
    end
  end

  def official_site
    if thing.official_site.present?
      if thing.official_site !~ /^https?:\/\//
        thing.official_site = "http://#{thing.official_site}"
      end
      link_to_with_icon "官方网站", "fa-li fa fa-globe", thing.official_site,
                        target: "_blank", title: "官方信息", rel: '_nofollow'
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
    topic = ' @KnewOne '
    if current_user == thing.author
      "我在#{topic}上分享了一个酷产品, #{title}: #{thing_url(thing, :refer => 'weibo')}"
    else
      "我在#{topic}发现了一个酷产品, #{title}: #{thing_url(thing, :refer => 'weibo')}"
      # TODO: Thanks user depends on provider
      # if current_user.current_auth && current_user != thing.author
      #   if current_user.equal_auth_provider?(thing.author)
      #     str += " (感谢 @#{thing.author.name} 分享)"
      #   elsif thing.author.current_auth
      #     str += " (感谢 #{thing.author.name} from #{thing.author.provider} 分享)"
      #   end
      # end
    end
  end

  def reviews(limit)
    thing.reviews.limit(limit)
  end

  def stage
    if thing.stage == :dsell
      if thing.valid_kinds.size == 0
        :concept
      else
        Kind::STAGES.keys.each do |s|
          return s if thing.valid_kinds.map(&:stage).include?(s)
        end
      end
    else
      thing.stage
    end
  end

  def stage_text
    (Thing::STAGES.merge Kind::STAGES)[stage]
  end

  def period
    return if thing.period.blank?
    time = time_tag thing.period, distance_of_time_in_words_to_now(thing.period)
    if thing.period > Time.now
      "还有 #{time} 结束"
    else
      "已结束"
    end.html_safe
  end

  def target
    number_to_currency thing.target, precision: 0, unit: "￥"
  end

  def investors_count
    show_count thing.investors.count
  end

  def invest_amount
    thing.investors.map(&:amount).reduce(&:+)
  end

  def invest_currency
    number_to_currency invest_amount, precision: 0, unit: "￥"
  end

  def content_for_invest_amount
    return unless thing.investors.count > 0
    "<em>#{invest_currency}</em><span> / </span><em>#{target}</em>".html_safe
  end

  def invest_progress
    amount = invest_amount
    return 0 if thing.target.blank? or thing.target <= 0 or amount.blank?
    amount/thing.target
  end

  def invest_percentage
    number_to_percentage invest_progress*100, precision: 2
  end

  def kinds
    thing.valid_kinds.map {|k| present(k)}
  end

  def options_for_kinds
    options_for_select kinds.map(&:build_option)
  end

  def categories
    Category.any_in(name: thing.categories)
  end

  def related_things
    thing.related_things.map {|t| present(t)}
  end
end
