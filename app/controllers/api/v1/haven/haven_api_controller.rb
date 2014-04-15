module Api
  module V1
    module Haven
      class HavenApiController < ApiController
        doorkeeper_for :all, scopes: [:haven]
      end
    end
  end
end
