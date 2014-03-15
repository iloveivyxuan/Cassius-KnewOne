# -*- coding: utf-8 -*-
module UsersHelper
  def user_avatar(user, size=:tiny)
    image_tag user.avatar.url(size), alt: user.name
  end

  def user_location(user)
    location = user.location
    return nil if location.blank?
    location
  end

  def provider_sync
    return nil unless current_user && current_user.current_auth
    raw "<label id='check_provider_sync' class='checkbox inline'><input type='checkbox' name='provider_sync' checked>分享到社交网络</label>"
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
                                   title: "个人网站", target: "_blank", class: 'website', rel: '_nofollow')
        when 'Twitter'
          html<< link_to_with_icon(nil, 'fa fa-twitter', v,
                                   title: "Twitter", target: "_blank", class: 'provider', rel: '_nofollow')
        when 'Weibo'
          html<< link_to_with_icon(nil, 'fa fa-weibo', v,
                                   title: "新浪微博", target: "_blank", class: 'provider', rel: '_nofollow')
        when 'Blog'
          html<< link_to_with_icon(nil, 'fa fa-rss', v,
                                   title: "博客", target: "_blank", class: 'website', rel: '_nofollow')
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
end
