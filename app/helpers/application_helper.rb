module ApplicationHelper

  # TODO: should be monkey patching into ActiveSupport
  def obj_to_s(obj)
    obj.class.to_s.demodulize.underscore
  end

  def page_css(file)
    content_for(:stylesheet, stylesheet_link_tag("views/#{file}"))
  end

  def calc_skip(size, num)
    (size > num) ? (size - num) : 0
  end

  def sanitize(html, options = {})
    html = ActionController::Base.helpers.sanitize(html, options)

    fragment = Nokogiri::HTML::DocumentFragment.parse(html)
    fragment.css('iframe:not([src])').remove

    fragment.to_html.html_safe
  end

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

  def link_or_login(name = nil, url = nil, html_options = {}, &block)
    if block_given?
      html_options = url || {}
      url = name
    end

    unless user_signed_in?
      html_options.merge!(data: {toggle: 'modal', target: '#login-modal', link: url_for(url)})
      url = '#'
    end

    if block_given?
      link_to(url, html_options, &block)
    else
      link_to(name, url, html_options)
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
    image_tag "logos/#{i}.png", class: 'shake', alt: brand, title: "#{brand}，根本停不下来~"
  end

  def page_title(title, is_root = false)
    if is_root
      title_str = title
    else
      title_str = "#{title} - "
    end

    content_for :title do
      title_str
    end
  end

  def page_keywords
    [content_for(:keywords), Settings.keywords].reject(&:blank?).join(',')
  end

  def page_description
    [content_for(:description), Settings.description].reject(&:blank?).join
  end

  def page_class
    ["#{controller_path.gsub('/', '_')}_#{action_name}",
      if browser.mobile?
        "mobile"
      elsif browser.tablet?
        "tablet"
      else
        "desktop"
      end,
      content_for(:page_class)].reject(&:blank?).join(' ')
  end

  def feed_link_tag
    feed_url = content_for?(:feed) ? content_for(:feed) : things_url(format: "atom")
    if content_for?(:rss)
      (auto_discovery_link_tag :atom, feed_url) + (auto_discovery_link_tag :rss, content_for(:rss))
    else
      auto_discovery_link_tag :atom, feed_url
    end
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

  def li(set_active = false, options = {}, &block)
    if set_active
      options[:class] = "#{options[:class]} active"
    end
    content_tag :li, options, &block
  end

  def time_ago_tag(time, css = '')
    timeago_tag(time, class: css)
  end

  def time_ago(time)
    time_ago_in_words(time)
  end

  def boolean_tag(val)
    val ? "yes" : "no"
  end

  def date_time_text(time)
    time.strftime '%Y-%m-%d %H:%M:%S'
  end

  def date_text(time)
    time.strftime '%Y-%m-%d'
  end

  def no_link_href
    '#'
  end

  def badge(num)
    num == 0 ? nil : num
  end

  def fullpath_with_modal(modal_id)
    path = request.fullpath
    path.gsub! /open_modal=[^&]*&?/, ''
    if path.include? '?'
      "#{path}&open_modal=#{modal_id}"
    else
      "#{path}?open_modal=#{modal_id}"
    end
  end

  def alpha_pay?
    cookies[:alpha] == "pay" || params[:alpha] == "pay"
  end

  def xeditable?(object)
    can?(:update, object)
  end

  def data_with_buy_tracker(category, label, data=nil)
    tracker = {
      action: "buy",
      category: "buy+#{category}",
      label: "buy+#{category}+#{label}"
    }

    data ? tracker.merge(data) : tracker
  end

  def data_with_login_tracker(category, label, auto_show_modal = true)
    if auto_show_modal
      {
        action: "login",
        category: "login+#{category}",
        label: "login+#{category}+#{label}",

        toggle: "modal",
        target: "#login-modal"
      }
    else
      {
        action: "login",
        category: "login+#{category}",
        label: "login+#{category}+#{label}",
      }
    end
  end

  def login_path(path = '')
    if browser.wechat?
      user_omniauth_authorize_path(:wechat, state: request.fullpath, scope: 'snsapi_base')
    else
      path.present? ? path : '#'
    end
  end
end
