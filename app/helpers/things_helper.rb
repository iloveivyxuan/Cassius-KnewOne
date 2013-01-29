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
end
