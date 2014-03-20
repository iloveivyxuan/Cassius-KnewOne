# -*- coding: utf-8 -*-
class GroupPresenter < ApplicationPresenter
  presents :group
  delegate :name, :members_count, to: :group

  def avatar(size=:tiny, options={})
    image_tag group.avatar.url(size), options.merge(alt: group.name)
  end

  def description
    simple_format group.description
  end

  def members(page, per)
    # Lazy loading users into corresponded members
    group.members.page(page).per(per).map(&:user)
  end
end
