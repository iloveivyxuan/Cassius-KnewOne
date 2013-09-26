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

  def brand
    "knewone"
  end

  def logo
    i = 1.upto(22).to_a.shuffle.first
    image_tag "logos/#{i}.png", alt: brand
  end

  def page_title
    raw [brand, content_for(:title)].reject(&:blank?).join('-')
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
    options[:class] += ' active' if content_for(:nav) == tab.to_s
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

  def redirect_back_or(path, flash = {})
    flash.each_pair do |k,v|
      flash[k] = v
    end
    redirect_to(session.delete(:previous_url) || path)
  end

  def date_time_text(time)
    time.strftime '%Y-%m-%d %H:%M:%S'
  end

  def no_link_href
    '#'
  end
end
