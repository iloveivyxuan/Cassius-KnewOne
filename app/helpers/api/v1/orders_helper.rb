module Api
  module V1
    module OrdersHelper
      def deliver_by_text(order)
        Order::DELIVER_METHODS[order.deliver_by]
      end

      def state_text(order)
        Order::STATES[order.state]
      end
    end
  end
end
