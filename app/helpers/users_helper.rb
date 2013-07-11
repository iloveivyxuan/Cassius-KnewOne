# -*- coding: utf-8 -*-
module UsersHelper
  def user_avatar(user, size=:tiny)
    image_tag user.avatar.url(size), alt: user.name
  end

  def user_location(user)
    return nil unless user.current_auth
    location = user.current_auth.location
    return nil if location.blank?
    content_tag(:i, "", class: "icon-map-marker") + location
  end

  def user_desciption(user)
    return nil unless user.current_auth
    user.current_auth.description
  end

  def provider_share(user)
    return nil unless user.current_auth
    provider = user.current_auth.provider
    raw({
            weibo: "<i class=\"icon-weibo\"></i><span>微博分享</span>",
            twitter: "<i class=\"icon-twitter\"></i><span>发Tweet</span>"
        }[provider.to_sym])
  end

  def user_links(user)
    sites = user.auths.collect(&:urls).reduce(&:merge) || {}
    sites.delete "Blog" if sites["Website"] == sites["Blog"]

    html = []
    sites.each_pair do |k, v|
      case k
        when 'Website'
          html<< link_to_with_icon(nil, 'icon-globe icon-large', v, title: "个人网站", target: "_blank", class: 'website')
        when 'Twitter'
          html<< link_to_with_icon(nil, 'icon-twitter icon-large', v, title: "Twitter 主页", target: "_blank", class: 'provider')
        when 'Weibo'
          html<< link_to_with_icon(nil, 'icon-weibo icon-large', v, title: "微博页面", target: "_blank", class: 'provider')
        when 'Blog'
          html<< link_to_with_icon(nil, 'icon-globe icon-large', v, title: "个人博客", target: "_blank", class: 'website')
      end
    end
    html.join.html_safe
  end

  def user_topic_wrapper(user, topic)
    return nil unless user.current_auth
    user.current_auth.topic_wrapper topic
  end
end
