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

      def stage(thing)
        if thing.stage == :dsell
          if thing.kinds.size == 0
            :concept
          else
            Kind::STAGES.keys.each do |s|
              return s if thing.kinds.map(&:stage).include?(s)
            end
          end
        else
          thing.stage
        end
      end
    end
  end
end
