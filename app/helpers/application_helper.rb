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

  def number_to_human(number)
    return number if number < 1000

    precision = number < 10000 ? 1 : 0

    content_tag :span, class: 'humanized_number', title: number do
      ActionController::Base.helpers.number_to_human(number, precision: precision)
    end
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
    "分享科技与设计产品，发现更好的生活"
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
      content_for(:page_class),
      if user_signed_in?
        "signed_in"
      else
        "signed_out"
      end
    ].reject(&:blank?).join(' ')
  end

  def browser_class
    browser.name.downcase
  end

  def env_class
    " production" if Rails.env.production?
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

  def time_ago_tag(time, klass = '')
    title = date_time_text(time)
    time_tag(time, time_ago_in_words(time), title: title, class: klass, 'data-time-ago' => time.iso8601)
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
    action = case category
             when "dsell"
               "buy_shop"
             when "adoption"
               "buy_adoption"
             else
               "buy_external"
             end

    tracker = {
      category: "thing",
      action: action,
      label: label
    }

    data ? tracker.merge(data) : tracker
  end

  def data_with_login_tracker(category, label, auto_show_modal = true)
    if auto_show_modal
      signin_legend = case category
                      when "dsell", "pre_order"
                        "登录后，购买商品"
                      when "kick"
                        "登录后，众筹商品"
                      when "domestic"
                        "登录后，网购商品"
                      when "abroad"
                        "登录后，海淘商品"
                      else
                        "登录"
                      end
      {
        action: "user",
        category: "login",
        label: "email",

        toggle: "modal",
        target: "#login-modal",
        "signin-legend" => signin_legend
      }
    else
      {
        action: "user",
        category: "register",
        label: "wechat",
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

  def lazy_image_tag(source, options = {})
    if browser.mobile?
      options['data'] ||= {}
      data = options['data'].merge(original: source)
      tag 'img', options.merge(class: 'js-lazy', data: data)
    else
      image_tag(source, options)
    end
  end

  def fancy_tracker(klass, object)
    { category: klass, action: "fancy", label: tracker_title(object) }
  end

  def tracker_title(object)
    case object.class
    when Feeling
      "#{object.thing.title} - #{object.content}"
    when Review
      "#{object.thing.title} - #{object.title}"
    when Topic
      "#{object.group.name} - #{object.title}"
    when Post
      "#{object.title}"
    else
      "unknown object #{object.id.to_s}"
    end
  end

  def share_btn_label
    if @review && @review.is_a?(Review)
      @review.title
    elsif @order && @order.is_a?(Order)
      @order.order_items.first.thing.title
    elsif @thing_list && @thing_list.is_a?(ThingList)
      @thing_list.name
    elsif @thing && @thing.is_a?(Thing)
      @thing.title
    elsif current_user
      current_user.name
    else
      request.path
    end
  end
end
