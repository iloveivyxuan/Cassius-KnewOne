module Haven
  class ApplicationController < ::ActionController::Base
    prepend_before_action :require_admin_signed_in
    before_action :logging
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

    private

    def logging
      logger.info "Current user: #{user_signed_in? ? current_user.id : 'guest'}"
      logger.info "Session: #{session.to_hash}"
      logger.info "> IP #{request.ip} Who #{user_signed_in? ? current_user.id : 'guest'} By #{request.method} What #{request.fullpath} When #{Time.now} From #{request.env['action_dispatch.request.unsigned_session_cookie']['previous_url']}"
    end
  end
end
