class NotificationsController < ApplicationController
  prepend_before_action :authenticate_user!
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
      @tabs = {}
      %w(thing reply friend fancy).each do |type|
        @tabs[type.to_sym] = @notifications.by_types(notification_types(type))
      end
      @active_tab_key = @tabs.map {|pair| pair[1].select {|i| !i.read?}.any? ? pair[0] : nil}.compact.first || :thing

      render 'notifications/index_xhr', layout: false
    else
      @unread_count = current_user.notifications.unread.count
      render 'notifications/index'
      mark_read
    end
  end

  def mark
    if params[:type]
      type = params[:type].split("_").last
      notifications = current_user.notifications.by_types(notification_types(type))
      notifications.set read: true
    end

    respond_to do |format|
      format.html { redirect_to notifications_path }
      format.json { head :no_content }
    end
  end

  private

  def mark_read
    @notifications.set read: true
  end

  def notification_types(type)
    case type
    when "thing"
      %w(stock new_review new_feeling)
    when "reply"
      %w(comment topic review feeling)
    when "friend"
      %w(following weibo_friend_joined)
    when "fancy"
      %w(love_feeling love_review love_topic fancy_thing fancy_list)
    end
  end
end
