module Api
  module V1
    module Official
      class OfficialApiController < ApiController
        doorkeeper_for :all, scopes: [:official]
      end
    end
  end
end
