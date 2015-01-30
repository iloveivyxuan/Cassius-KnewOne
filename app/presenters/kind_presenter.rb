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
    return '价格待定' if kind.stage == :pre_order && kind.price.to_i <= 0

    str = price_format(kind.price)
    min_point = kind.minimal_bong_point
    max_point = kind.maximal_bong_point
    text = if min_point.zero? && max_point > 0
             "可使用活跃点抵扣 0 - #{kind.maximal_bong_point} 元"
           elsif !min_point.zero? && (min_point != max_point)
             "仅限活跃点用户购买，且可使用活跃点折扣 #{min_point} - #{max_point} 元"
           elsif !min_point.zero? && (min_point == max_point)
             "仅限活跃点用户购买，需支付活跃点 #{min_point}"
           end
    if kind.can_consume_bong_point?
      str += <<-HTML
          <small>#{text}</small>
      HTML
    end
    str.html_safe
  end

  def limit
    "<em>#{kind.stock}</em> 库存".html_safe
  end

  def option_for_select(with_price=false)
    text = with_price ? title.concat(price) : title
    content_tag :option, text, value: id, data: {
      stock: stock,
      max: max,
      price: price,
      photo: photo_number,
      estimated: estimated_at
    }, class: "kind_option", disabled: (stock <= 0)
  end
end
