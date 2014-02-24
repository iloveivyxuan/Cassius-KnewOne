# -*- coding: utf-8 -*-
module ApplicationHelper
  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end

  def link_to_with_icon(body, icon_class, options = {}, html_options = {})
    link_to options, html_options do
      content_tag(:i, "", class: icon_class) + body.to_s
    end
  end

  def nav_tab_link_with_icon(tab, body, icon_class, options = {}, html_options = {})
    html_options[:class] ||= 'list-group-item'
    if content_for(:nav) == tab.to_s
      html_options[:class] += ' active'
    end

    link_to_with_icon body, icon_class, options, html_options
  end

  def back_btn
    link_to '后退', 'javascript: history.go(-1)', class: 'btn'
  end

  def brand
    "KnewOne"
  end

  def slogan
    "在这里，分享新奇酷产品和你的体验"
  end

  def logo
    i = 1.upto(21).to_a.shuffle.first
    image_tag "logos/#{i}.png", alt: brand
  end

  def page_title
    raw [content_for(:title), brand].reject(&:blank?).join('-')
  end

  def page_keywords
    [content_for(:keywords), Settings.keywords].reject(&:blank?).join(',')
  end

  def page_description
    [content_for(:description), Settings.description].reject(&:blank?).join('; ')
  end

  def page_class
    [controller_name, "#{controller_path.gsub('/', '_')}_#{action_name}", content_for(:page_class)].reject(&:blank?).join(' ')
  end

  def feed_link_tag
    feed_url = content_for?(:feed) ? content_for(:feed) : things_url(format: "atom")
    auto_discovery_link_tag :atom, feed_url
  end

  def notification
    [:error, :alert, :notice, :info, :success].each do |type|
      message = flash.now[type] || flash[type]
      return content_tag :div, class: "alert alert-#{type}" do
        button_tag('x', type: 'button', class: 'close',
                   data: {dismiss: 'alert'}) + message
      end if message
    end
    nil
  end

  def nav_tab(tab, options = {})
    options[:class] ||= ''
    if content_for(:nav) == tab.to_s || options[:nav] == tab.to_s
      options[:class] += ' active'
    end
    content_tag(:li, options) {yield}
  end

  def time_ago_tag(time)
    time_tag time, time_ago(time)
  end

  def time_ago(time)
    time_ago_in_words(time)+"前"
  end

  def boolean_tag(val)
    val ? "yes" : "no"
  end

  def date_time_text(time)
    time.strftime '%Y-%m-%d %H:%M:%S'
  end

  def no_link_href
    '#'
  end

  def alpha_pay?
    cookies[:alpha] == "pay" || params[:alpha] == "pay"
  end
end
