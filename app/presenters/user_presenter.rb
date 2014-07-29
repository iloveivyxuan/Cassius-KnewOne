class UserPresenter < ApplicationPresenter
  presents :user
  delegate :name, to: :user

  def path
    user_path(user)
  end

  def avatar(size=:small, options={})
    image_tag user.avatar.url(size), options.merge(alt: user.name)
  end

  def as_author(size=:small)
    link_to(avatar(size), user, class: "author_avatar").concat link_to(name, user, class: "author_name")
  end

  def as_author_with_profile(size=:small)
    link_to(avatar(size), user, add_popover_options(class: "author_avatar"))
      .concat(link_to(name.truncate(20), user, add_popover_options(class: "author_name")))
  end

  def topic_wrapper(topic)
    return nil unless user.current_auth
    user.current_auth.topic_wrapper topic
  end

  def link_to_with_avatar(size, options={}, img_options={})
    link_to avatar(size, img_options), user, add_popover_options(options)
  end

  def link_to_with_name(options={})
    link_to name, user, options
  end

  def link_to_with_popoverable_name(options={})
    link_to_with_name(add_popover_options(options))
  end

  private

  def add_popover_options(options)
    options.merge(data: {'popover-profile' => user.id.to_s})
  end
end
