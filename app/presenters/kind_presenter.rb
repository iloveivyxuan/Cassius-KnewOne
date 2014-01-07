# -*- coding: utf-8 -*-
class KindPresenter < ApplicationPresenter
  presents :kind
  delegate :title, :id, :photo_number, :stock, :max_per_buy, to: :kind

  def estimated_at
    if kind.stage == :ship and kind.estimates_at.present? and kind.estimates_at > Time.now
      time_tag kind.estimates_at, distance_of_time_in_words_to_now(kind.estimates_at)
    end.try(:gsub, "\"", "'")
  end

  def content_for_estimated_at
    e = estimated_at
    return if e.blank?
    "预估将于 #{e} 后发货 ".html_safe
  end

  def max
    kind.max_buyable
  end

  def price
    price_format(kind.price)
  end

  def limit
    "<em>#{kind.stock}</em> 库存".html_safe
  end

  def build_option
    [title, id, data: {
        stock: stock,
        max: max,
        price: price,
        photo: photo_number,
        estimated: estimated_at
    }, class: "kind_option", disabled: (stock <= 0)]
  end
end
