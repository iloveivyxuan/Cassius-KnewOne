class UserPresenter < ApplicationPresenter
  presents :user
  delegate :name, to: :user

  def avatar(size=:tiny)
    image_tag user.avatar.url(size), alt: user.name
  end

  def as_author
    link_to(avatar, user).concat link_to(name, user)
  end

  def topic_wrapper(topic)
    user.current_auth.topic_wrapper topic
  end
end
