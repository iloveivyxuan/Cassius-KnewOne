module Api
  module V1
    module Official
      class BalancesController < OfficialApiController
        def show
          @balance = current_user.balance
        end
      end
    end
  end
end
