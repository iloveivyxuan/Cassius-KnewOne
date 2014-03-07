# -*- coding: utf-8 -*-
module NotificationsHelper
  def render_notification(n)
    render "notifications/#{n.type}", notification: n
  end
end
