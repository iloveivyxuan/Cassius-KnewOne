# -*- coding: utf-8 -*-
module Haven
  class ApplicationController < ::ActionController::Base
    layout 'application'
    prepend_before_action :authenticate_admin!

    protected

    def authenticate_admin!
      raise ActionController::RoutingError.new('Not Found') unless user_signed_in? && current_user.staff?
    end
  end
end
