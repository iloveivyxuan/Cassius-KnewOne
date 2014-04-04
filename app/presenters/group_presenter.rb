# -*- coding: utf-8 -*-
class GroupPresenter < ApplicationPresenter
  presents :group
  delegate :name, :members_count, :topics_count, :public?, :private?, to: :group

  def url
    group_url(group)
  end

  def avatar(size=:small, options={})
    image_tag group.avatar.url(size), options.merge(alt: group.name)
  end

  def description
    simple_format group.description
  end

  def members_aside
    group.members.limit(9).map { |m| present(m.user) }
  end

  def founder
    present(group.founder).as_author(:tiny) if group.founder
  end

  def member?
    group.has_member? current_user
  end

  def fancies_count
    @fancies_count ||= group.fancies.count
  end

  def fancies_aside
    group.fancy_ids.last(3).reverse.map do |id|
      present(Thing.where(id: id).first)
    end.compact
  end
end
