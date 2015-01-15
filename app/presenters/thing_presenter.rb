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
    lazy_image_tag photo_url(size), options.merge(alt: title)
  end

  def content(is_fold = true)
    footer_html = ''
    footer_html += official_site || ''
    footer_html += link_to('删除', thing, method: :delete,
              class: 'btn btn--square btn--cancel btn--delete',
              data: {confirm: '您确定要删除这个产品吗?'}) if can?(:destroy, thing)
    footer = content_tag(:footer, class: 'clearfix') do
      footer_html.html_safe
    end

    content_tag :div, class: "body post_content #{is_fold ? 'is_folded' : ''}" do
      sanitize(thing.content).concat(footer)
    end
  end

  def price
    if thing.price.present?
      price_format thing.price, thing.price_unit
    else
      ""
    end
  end

  def mobile_price
    return price_format(thing.price, thing.price_unit) unless thing.stage == :dsell
    if thing.price.present?
      price = price_format thing.kinds.map(&:price).sort.first, thing.price_unit
      price.concat(" 起") if thing.kinds.map(&:price).uniq.size > 1
      price
    else
      ""
    end
  end

  def shopping_desc(length = 48)
    return if thing.shopping_desc.blank?
    strip_tags(thing.shopping_desc).truncate(length).html_safe
  end

  def render_shopping_desc
    su = shopping_desc
    return unless su

    render partial: 'things/shopping_desc',
    locals: {summary: su, tp: self}
  end

  def render_shopping_desc_modal
    render partial: 'things/shopping_desc_modal',
           locals: {title: title, details: thing.shopping_desc.html_safe, tp: self}
  end

  def concept
  end

  def pre_order
    if thing.valid_kinds.blank?
      concept
    else
      render partial: 'cart_items/new', locals: {tp: self}
    end
  end

  def domestic
    return concept unless thing.shop.present?

    link_to_with_icon "网购", "fa fa-location-arrow fa-lg", buy_thing_path(thing), title: title,
    class: "btn btn--online_shopping buy_button", target: "_blank", rel: 'nofollow',
    data: data_with_buy_tracker("domestic", thing.title)
  end

  def kick
    return concept unless thing.shop.present?

    link_to_with_icon "众筹", "fa fa-fire fa-lg", buy_thing_path(thing),
    title: title, class: "btn btn--kick buy_button", target: "_blank", rel: 'nofollow',
    data: data_with_buy_tracker("kick", thing.title)
  end

  def abroad
    return concept unless thing.shop.present?

    link_to_with_icon "海淘", "fa fa-plane fa-lg", buy_thing_path(thing),
    title: title, class: "btn btn--online_shopping buy_button", target: "_blank", rel: 'nofollow',
    data: data_with_buy_tracker("abroad", thing.title)
  end

  def dsell
    if thing.valid_kinds.blank?
      concept
    else
      render partial: 'cart_items/new', locals: {tp: self}
    end
  end

  def adoption
    return nil unless thing.adoption
    render 'things/adopt', tp: self
  end

  def buy
    @buy ||= respond_to?(thing.stage) ? send(thing.stage) : concept
  end

  def official_site
    if thing.official_site.present?
      if thing.official_site !~ /^https?:\/\//
        thing.official_site = "http://#{thing.official_site}"
      end
      link_to_with_icon "来源网站", "fa fa-globe", thing.official_site,
      class: 'official_site', target: "_blank", title: "来源信息", rel: 'nofollow'
    end
  end

  def fancy_path
    fancy_thing_path(thing)
  end

  def owned?
    user_signed_in? and thing.owned?(current_user)
  end

  def owners_count
    content_tag :span, number_to_human(thing.owners_count), class: "owners_count"
  end

  def owners
    thing.owners.desc(:created_at).limit(10)
  end

  def has_owner?
    thing.owners_count > 0
  end

  def has_review?
    thing.reviews_count > 0
  end

  def reviews_count
    show_count thing.reviews_count
  end

  def feelings_count
    show_count thing.feelings_count
  end

  def reviews(limit)
    thing.reviews.desc(:is_top, :lovers_count, :created_at).limit(limit)
  end

  def feelings(limit=10)
    thing.feelings.desc(:lovers_count, :created_at).limit(limit)
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

  def kinds
    thing.valid_kinds.map {|k| present(k)}
  end

  def options_for_kinds
    kinds.map(&:option_for_select).join
  end

  def options_for_kinds_with_price
    kinds.map { |kind| kind.option_for_select(with_price: true) }.join
  end

  def categories(depth=1)
    thing.categories.gte(depth: depth)
  end

  def related_things(size = 10)
    if @_related_things && @_related_things.size >= size
      return @_related_things.take(size)
    end

    @_related_things = thing.related_things(size).map {|t| present(t)}
  end

  def fancied?
    user_signed_in? and thing.fancied?(current_user)
  end

  def fanciers_count
    content_tag :span, number_to_human(thing.fanciers_count), class: "fanciers_count"
  end

  def share_content
    if thing.author == current_user
      "我在 @KnewOne 分享了 #{title} "
    else
      "推荐 #{share_author_name} 在 #{share_topic} 发布的产品 #{title} "
    end + thing_url(thing, refer: :share)
  end

  def share_pic(size)
    photo_url size
  end

  def can_consume_bong_point?
    thing.kinds.map(&:can_consume_bong_point?).reduce &:|
  end
end
