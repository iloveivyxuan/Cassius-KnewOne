module Haven
  class ApplicationController < ::ActionController::Base
    prepend_before_action :require_admin_signed_in
    before_action :set_notification

    protected

    def require_admin_signed_in
      if !user_signed_in? || !current_user.staff?
        raise ActionController::RoutingError.new('Not Found')
      end
    end

    def redirect_back_or(path, flash = {})
      flash.each_pair do |k, v|
        flash[k] = v
      end
      url = params[:redirect_from].present? ? params[:redirect_from] : path # Avoiding querystring like redirect_from=&
      redirect_to(url, flash)
    end

    def set_notification
      if user_signed_in?
        @header_notifications = current_user.notifications.unread
      end
    end
  end
end
