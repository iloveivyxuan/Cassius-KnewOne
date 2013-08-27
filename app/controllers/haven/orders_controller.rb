module Haven
  class OrdersController < ApplicationController
    load_and_authorize_resource :order, class: ::Order

    def index
    end

    def show
    end

    def ship
      @order.ship!

      redirect_to haven_orders_path
    end
  end
end
