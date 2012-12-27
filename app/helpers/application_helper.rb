module ApplicationHelper
  def brand
    "making.im"
  end

  def page_title
    [brand, content_for(:title)].reject(&:blank?).join('-')
  end

  def notification
    [:error, :alert, :notice, :info, :success].each do |type|
      message = flash.now[type] || flash[type]
      if message
        return content_tag :div, class: "alert alert-#{type}" do
          button_tag('x', type: 'button', class: 'close',
                     data: {dismiss: 'alert'}) + message
        end
      end
    end
    nil
  end

  def controller_javascript_include_tag
    javascript_include_tag controller_name
  end
end
