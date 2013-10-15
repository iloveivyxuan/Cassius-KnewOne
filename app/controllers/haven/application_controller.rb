# -*- coding: utf-8 -*-
module Haven
  class ApplicationController < ::ActionController::Base
    layout 'application'
    before_filter :authenticate_admin!

    private

    def authenticate_admin!
      raise ActionController::RoutingError.new('Not Found') unless user_signed_in? && current_user.role?(:admin)
    end
  end
end
