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
    content_tag :div, class: "body post_content is_folded" do
      sanitize(raw thing.content)
    end if thing.content.present?
  end

  def price
    return @price if @price
    kinds_price = thing.valid_kinds.map(&:price).uniq
    p = if kinds_price.present?
          kinds_price.min
        elsif thing.price.present?
          thing.price
        end
    @price = p ? price_format(p, thing.price_unit) : nil
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
    link_to_with_icon "网购", "fa fa-location-arrow fa-lg", buy_thing_path(thing),
    title: title, class: "btn btn-info btn-block buy_button track_event", target: "_blank", rel: '_nofollow',
    data: {
      action: "buy",
      category: "domestic",
      label: "buy+domestic+#{title}"
    }
  end

  def kick
    return concept unless thing.shop.present?
    link_to_with_icon "众筹", "fa fa-fire fa-lg", buy_thing_path(thing),
    title: title, class: "btn btn-warning btn-block buy_button track_event", target: "_blank", rel: '_nofollow',
    data: {
      action: "buy",
      category: "kick",
      label: "buy+kick+#{title}"
    }
  end

  def abroad
    return concept unless thing.shop.present?
    link_to_with_icon "海淘", "fa fa-plane fa-lg", buy_thing_path(thing),
    title: title, class: "btn btn-info btn-block buy_button track_event", target: "_blank", rel: '_nofollow',
    data: {
      action: "buy",
      category: "abroad",
      label: "buy+abroad+#{title}"
    }
  end

  def dsell
    if thing.valid_kinds.blank?
      concept
    else
      render partial: 'cart_items/new', locals: {tp: self}
    end
  end

  def buy
    @buy ||= respond_to?(thing.stage) ? send(thing.stage) : concept
  end

  def official_site
    if thing.official_site.present?
      if thing.official_site !~ /^https?:\/\//
        thing.official_site = "http://#{thing.official_site}"
      end
      link_to_with_icon "来源网站", "fa-li fa fa-globe", thing.official_site,
      target: "_blank", title: "来源信息", rel: '_nofollow'
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

  def has_owner?
    thing.owners.count > 0
  end

  def has_review?
    thing.reviews.count > 0
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

  def feelings_count
    show_count thing.feelings.count
  end

  def reviews(limit)
    thing.reviews.desc(:is_top, :lovers_count, :created_at).limit(limit)
  end

  def feelings(limit)
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

  def categories
    Category.any_in(name: thing.categories)
  end

  def related_things(size = 10)
    @_related_things ||= thing.related_things(size).map {|t| present(t)}
  end

  def fancied?
    user_signed_in? and thing.fancied?(current_user)
  end

  def fanciers_count
    content_tag :span, thing.fanciers_count, class: "fanciers_count"
  end

  def groups_count
    show_count thing.fancy_groups.count
  end

  def share_content
    if thing.author == current_user
      "我在#{share_topic} 分享了一个酷产品: #{title} ! "
    else
      "我在#{share_topic} 发现了一个酷产品: 由 #{share_author_name} 分享的 #{title} ! "
    end + thing_url(thing, refer: 'weibo')
  end

  def share_pic(size)
    photo_url size
  end
end
