module Api
  module V1
    module ThingsHelper
      def price(thing)
        kinds_price = thing.kinds.map(&:price).uniq
        p = if kinds_price.present?
              kinds_price.min
            elsif thing.price.present?
              thing.price
            end

        if p.to_i > 0
          p_text = number_to_currency(p, precision: 2, unit: (thing.price_unit || '￥'))
          p_text << "起" if kinds_price.size > 1
          p_text
        end
      end

      def invest_amount(thing)
        thing.investors.map(&:amount).reduce(&:+)
      end
    end
  end
end
