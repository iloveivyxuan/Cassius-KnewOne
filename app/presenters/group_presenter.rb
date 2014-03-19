# -*- coding: utf-8 -*-
class GroupPresenter < ApplicationPresenter
  presents :group
  delegate :name, to: :group

  def avatar(size=:tiny, options={})
    image_tag group.avatar.url(size), options.merge(alt: group.name)
  end

  def description
    content_tag :blockquote, simple_format(group.description)
  end
end
