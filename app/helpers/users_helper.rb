# -*- coding: utf-8 -*-
module UsersHelper
  def user_avatar(user, size=:tiny)
    image_tag user.avatar.url(size), alt: user.name
  end

  def user_location(user)
    location = user.location
    return nil if location.blank?
    fa_icon("map-marker") + location
  end

  def provider_sync
    return nil unless current_user && current_user.current_auth
    raw "<label id='check_provider_sync' class='checkbox inline'><input type='checkbox' name='provider_sync' checked>分享到社交网络</label>"
  end

  def user_links(user)
    sites = user.auths.collect(&:urls).reduce(&:merge) || {}
    sites.delete "Blog" if sites["Website"] == sites["Blog"]

    html = []
    sites.each_pair do |k, v|
      case k
        when 'Website'
          html<< link_to_with_icon(nil, 'fa fa-globe fa-lg', v, title: "个人网站", target: "_blank", class: 'website')
        when 'Twitter'
          html<< link_to_with_icon(nil, 'fa fa-twitter fa-lg', v, title: "Twitter 主页", target: "_blank", class: 'provider')
        when 'Weibo'
          html<< link_to_with_icon(nil, 'fa fa-weibo fa-lg', v, title: "微博页面", target: "_blank", class: 'provider')
        when 'Blog'
          html<< link_to_with_icon(nil, 'fa fa-globe fa-lg', v, title: "个人博客", target: "_blank", class: 'website')
      end
    end
    html.join.html_safe
  end

  def user_topic_wrapper(user, topic)
    return nil unless user.current_auth
    user.current_auth.topic_wrapper topic
  end
end
