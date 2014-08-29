class NotificationsController < ApplicationController
  prepend_before_action :authenticate_user!
  after_action :mark_read, only: [:index]
  skip_before_action :require_not_blocked

  def index
    @notifications = current_user.notifications.page params[:page]

    case params[:scope]
      when 'unread'
        @notifications = @notifications.unread
      when 'read'
        @notifications = @notifications.marked_as_read
    end

    if request.xhr?
      @tabs = {
          importants: @notifications.by_types(%w(stock weibo_friend_joined comment new_review new_feeling topic feeling review)),
          relations: @notifications.by_types(%w(following)),
          things: @notifications.by_types(%w(love_feeling love_review love_topic fancy_thing fancy_list))
      }
      @active_tab_key = @tabs.map {|pair| pair[1].select {|i| !i.read?}.any? ? pair[0] : nil}.compact.first || :importants

      render 'notifications/index_xhr', layout: false
    else
      @unread_count = current_user.notifications.unread.count
      render 'notifications/index'
    end
  end

  def mark
    current_user.notifications.mark_as_read

    respond_to do |format|
      format.html { redirect_to notifications_path }
      format.json { head :no_content }
    end
  end

  private

  def mark_read
    @notifications.set read: true
  end
end
