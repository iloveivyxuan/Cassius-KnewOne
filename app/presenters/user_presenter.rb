class UserPresenter < ApplicationPresenter
  presents :user
  delegate :name, to: :user

  def avatar(size=:tiny)
    image_tag user.avatar.url(size), alt: user.name
  end

  def as_author
    link_to(avatar(:small), user).concat link_to(name, user)
  end

  def topic_wrapper(topic)
    user.current_auth.topic_wrapper topic
  end

  def link_to_with_avatar(size)
    link_to avatar(size), user
  end

  def link_to_with_name
    link_to name, user
  end
end
