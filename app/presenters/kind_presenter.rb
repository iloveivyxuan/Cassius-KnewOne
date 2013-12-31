class KindPresenter < ApplicationPresenter
  presents :kind
  delegate :title, :id, :price, :photo_number, :stock, :max_per_buy, to: :kind

  def estimated_at
    if kind.stage == :ship and kind.estimates_at.present? and kind.estimates_at > Time.now
      time_tag kind.estimates_at, distance_of_time_in_words_to_now(kind.estimates_at)
    end.try(:gsub, "\"", "'")
  end

  def max
    [stock, max_per_buy].select do |i|
      i.present? and i > 0
    end.min
  end

  def build_option
    [title, id, data: {
         stock: stock,
         max: max,
         price: price_format(price),
         photo: photo_number,
         estimated: estimated_at
     }, class: "kind_option", disabled: (stock <= 0)]
  end
end
