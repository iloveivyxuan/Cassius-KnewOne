module Api
  module V1
    module ThingsHelper
      def price(thing)
        kinds_price = thing.kinds.map(&:price).uniq
        if kinds_price.present?
          kinds_price.min
        elsif thing.price.present?
          thing.price
        else
          nil
        end
      end

      def invest_amount(thing)
        thing.investors.map(&:amount).reduce(&:+)
      end
    end
  end
end
