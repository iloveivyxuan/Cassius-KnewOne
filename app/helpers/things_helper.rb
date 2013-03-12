# -*- coding: utf-8 -*-
module ThingsHelper
  def thing_title(thing)
    [thing.title, thing.subtitle].reject(&:blank?).join(' - ')
  end

  def thing_price(thing)
    if thing.price.to_i > 0
      content_tag :small,
        number_to_currency(thing.price, precision: 2, unit: thing.price_unit)
    end
  end

  def thing_shop(thing)
    link_to buy_thing_path(thing), class: "track_event thing_shop", target: '_blank', data: {
      # analystics
      action: "buy",
      category: "thing",
      label: thing.title,
      # popover
      placement: "bottom",
      title: "暂时不能购买",
      content: "抱歉，目前还没有合适的渠道让您购买到此商品，不过，我们会一直追踪此商品的最新动向，一旦您所在的地区可以购买，我们会第一时间提供最靠谱的购买渠道，敬请期待"
    } do
        button_tag class: "btn btn-success #{'disabled' if thing.shop.blank?}" do
          content_tag(:i, "", class: "icon-shopping-cart")
          .concat content_tag(:span, "购买")
        end
    end
  end

  def thing_photo_url(thing, size)
    thing.photos.first.url(size)
  end

  def thing_photo(thing, size, options = {})
    url = thing_photo_url(thing, size)
    image_tag url, options.merge(alt: thing_title(thing))
  end

  def thing_fanciers(thing)
    c = thing.fanciers.count
    if c > 0
      content_tag :span, class: "fanciers" do
        content_tag(:i, "", class: "icon-heart")
        .concat content_tag(:small, c)
      end
    end
  end

  def thing_owners(thing)
    c = thing.owners.count
    if c > 0
      content_tag :span, class: "owners" do
        content_tag(:i, "", class: "icon-bookmark")
        .concat content_tag(:small, c)
      end
    end
  end

  def thing_reviews(thing)
    c = thing.reviews.count
    if c > 0
      content_tag :span, class: "reviews_count" do
        content_tag(:i, "", class: "icon-file-alt")
        .concat content_tag(:small, c)
      end
    end
  end

  def thing_share_content(thing)
    %{我在##{brand}#发现了一个酷产品, #{thing_title(thing)}: #{thing_url(thing)}
}
  end
end
