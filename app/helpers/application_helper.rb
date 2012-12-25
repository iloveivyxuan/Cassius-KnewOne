module ApplicationHelper
  def brand
    "making.im"
  end

  def page_title
    [brand, content_for(:title)].reject(&:blank?).join('-')
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
