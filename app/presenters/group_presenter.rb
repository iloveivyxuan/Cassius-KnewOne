class GroupPresenter < ApplicationPresenter
  presents :group
  delegate :name, :members_count, :topics_count, :public?, :private?, to: :group

  def path
    group_path(group)
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
end
