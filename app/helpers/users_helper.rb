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
<<<<<<< HEAD
            weibo: "<i class=\"icon-eye-open\"></i><span>微博分享</span>",
            twitter: "<i class=\"icon-twitter\"></i><span>发Tweet</span>"
        }[provider.to_sym])
  end

  def user_links(user)
    sites = user.auths.collect(&:urls).reduce(&:merge) || {}
    sites.delete "Blog" if sites["Website"] == sites["Blog"]

    sites.each_pair do |k, v|
      case k
        when 'Website'
          link_to v, class: "website",
                  title: "个人网站", target: "_blank" do
            content_tag :i, "", class: "icon-globe icon-large"
          end
        when 'Twitter'
          link_to v, class: "provider",
                  title: "Twitter 主页", target: "_blank" do
            content_tag :i, "", class: "icon-twitter icon-large"
          end
        when 'Weibo'
          link_to v, class: "provider",
                  title: "微博页面", target: "_blank" do
            content_tag :i, "", class: "icon-eye-open icon-large"
          end
        when 'Blog'
          link_to v, class: "website",
                  title: "个人博客", target: "_blank" do
            content_tag :i, "", class: "icon-globe icon-large"
          end
      end
    end
    nil
=======
      weibo: "<i class=\"icon-weibo\"></i><span>微博分享</span>",
      twitter: "<i class=\"icon-twitter\"></i><span>发Tweet</span>"
    }[provider.to_sym])
  end

  def user_provider(user)
    send "#{user.current_auth.provider}_home", user.current_auth
>>>>>>> staging
  end

  def user_topic_wrapper(user, topic)
    return nil unless user.current_auth
    user.current_auth.topic_wrapper topic
  end
<<<<<<< HEAD
=======

  def twitter_website(auth)
    return if auth.urls["Website"].blank?
    link_to auth.urls["Website"], class: "website",
    title: "个人网站", target: "_blank" do
      content_tag :i, "", class: "icon-globe icon-large"
    end
  end

  def twitter_home(auth)
    return if auth.urls["Twitter"].blank?
    link_to auth.urls["Twitter"], class: "provider",
    title: "Twitter 主页", target: "_blank" do
      content_tag :i, "", class: "icon-twitter icon-large"
    end
  end

  def weibo_website(auth)
    return if auth.urls["Blog"].blank?
    link_to auth.urls["Blog"], class: "website",
    title: "个人博客", target: "_blank" do
      content_tag :i, "", class: "icon-globe icon-large"
    end
  end

  def weibo_home(auth)
    return if auth.urls["Weibo"].blank?
    link_to auth.urls["Weibo"], class: "provider",
    title: "微博页面", target: "_blank" do
      content_tag :i, "", class: "icon-weibo icon-large"
    end
  end

>>>>>>> staging
end
