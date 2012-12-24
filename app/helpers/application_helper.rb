module ApplicationHelper
  def brand
    "Making"
  end

  def page_title(title)
    title.blank? ? "" : " | #{title}"
  end

  def notification_content(message, type)
    content_tag :div, class: "alert alert-#{type}" do
      button_tag('x', type: 'button', class: 'close',
                 'data-dismiss' => 'alert') + message
    end
  end

  def notification
    [:error, :alert, :notice, :info, :success].each do |type|
      message = flash.now[type] || flash[type]
      return notification_content(message, type) if message
    end
    nil
  end
end
