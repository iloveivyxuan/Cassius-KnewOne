# -*- coding: utf-8 -*-
module ThingsHelper
  def thing_title(thing)
    [thing.title, thing.subtitle].reject(&:blank?).join(' - ')
  end

  def thing_price(thing)
    if thing.price.to_i > 0
      content_tag :small, "¥#{thing.price.to_i}"
    end
  end

  def thing_photo(thing, size, options = {})
    url = thing.photos.first.url(size)
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

  def thing_share_content(thing)
    %{我在##{brand}#发现了一个酷产品, #{thing_title(thing)}: #{thing_url(thing)}
}
  end
end
