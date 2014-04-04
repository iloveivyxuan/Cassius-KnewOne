# -*- coding: utf-8 -*-
class UserPresenter < ApplicationPresenter
  presents :user
  delegate :name, to: :user

  def url
    user_url(user)
  end

  def avatar(size=:small, options={})
    image_tag user.avatar.url(size), options.merge(alt: user.name)
  end

  def as_author(size=:small)
    link_to(avatar(size), user, class: "author_avatar").concat link_to(name, user, class: "author_name")
  end

  def topic_wrapper(topic)
    return nil unless user.current_auth
    user.current_auth.topic_wrapper topic
  end

  def link_to_with_avatar(size, options={})
    link_to avatar(size), user, options.merge(title: user.name)
  end

  def link_to_with_name
    link_to name, user
  end
end
