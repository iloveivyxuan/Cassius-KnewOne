# -*- coding: utf-8 -*-
module Haven
  class ApplicationController < ::ActionController::Base
    prepend_before_action :authenticate_admin!

    protected

    def authenticate_admin!
      raise ActionController::RoutingError.new('Not Found') unless user_signed_in? && current_user.staff?
    end

    def redirect_back_or(path, flash = {})
      flash.each_pair do |k, v|
        flash[k] = v
      end
      url = params[:redirect_from].present? ? params[:redirect_from] : path # Avoiding querystring like redirect_from=&
      redirect_to(url, flash)
    end
  end
end
