module Api
  module V1
    class OrdersController < ApiController
      doorkeeper_for :all, except: [:tenpay_callback, :alipay_callback]

      def show

      end

      def index

      end

      def create

      end

      def cancel

      end

      def tenpay_callback

      end

      def alipay_callback

      end
    end
  end
end
