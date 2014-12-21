module UsersHelper
  def user_avatar(user, size=:small)
    image_tag user.avatar.url(size), alt: user.name
  end

  def provider_sync(checked = true)
    return nil unless current_user && current_user.current_auth
    raw "<label id='check_provider_sync'><input type='checkbox' name='provider_sync' #{'checked' if checked}>分享到社交网络</label>"
  end

  def user_links(user)
    sites = user.auths.collect(&:urls).compact.reduce(&:merge) || {}
    sites.delete "Blog" if sites["Website"] == sites["Blog"]

    html = []
    sites.each_pair do |k, v|
      next if v.blank?

      case k
        when 'Website'
          html<< link_to_with_icon(nil, 'fa fa-globe', v,
                                   title: "个人网站", target: "_blank", class: 'website', rel: 'nofollow')
        when 'Twitter'
          html<< link_to_with_icon(nil, 'fa fa-twitter', v,
                                   title: "Twitter", target: "_blank", class: 'provider', rel: 'nofollow')
        when 'Weibo'
          html<< link_to_with_icon(nil, 'fa fa-weibo', v,
                                   title: "新浪微博", target: "_blank", class: 'provider', rel: 'nofollow')
        when 'Blog'
          html<< link_to_with_icon(nil, 'fa fa-rss', v,
                                   title: "博客", target: "_blank", class: 'website', rel: 'nofollow')
      end
    end

    if user_signed_in? && current_user.staff? && user.email.present?
      html<< link_to_with_icon(nil, 'fa fa-envelope', "mailto:#{user.email}", title: '邮箱', class: 'provider')
    end

    html.join.html_safe
  end

  def user_topic_wrapper(user, topic)
    return nil unless user.current_auth
    user.current_auth.topic_wrapper topic
  end

  def render_user_links(user)
    html = user_links(user)
    return if html.blank?

    content_tag :dd, nil, class: 'url', title: '社交网络', itemprop: 'url' do
          content_tag(:div, nil, class: 'data') { user_links(user) }
    end
  end

  def render_user_location(user)
    return if user.location.blank?

    content_tag :dd, nil, class: 'location', title: '地区' do
      content_tag(:label, nil) { content_tag(:i, nil, class: 'fa fa-map-marker') } +
          content_tag(:address, user.location, class: 'data')
    end
  end

  def symbolize_gender(gender)
    case gender
      when '男' then '♂'
      when '女' then '♀'
      else ''
    end
  end

  def render_user_gender(user)
    if user.gender.present?
      content_tag :small, class: 'gender' do
        symbolize_gender(user.gender)
      end
    end
  end
end
