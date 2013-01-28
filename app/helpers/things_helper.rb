# -*- coding: utf-8 -*-
module ThingsHelper
  def thing_title(thing)
    [thing.title, thing.subtitle].reject(&:blank?).join(' - ')
  end

  def thing_price(thing)
    content_tag :small, "¥#{thing.price.to_i}"
  end

  def thing_photo(thing)
    thing.photos.first.url(:middle)
  end
end
