# -*- coding: utf-8 -*-
class TopicPresenter < PostPresenter
  presents :topic

  def path
    [topic.group, topic]
  end

  def edit_path
    [:edit, topic.group, topic]
  end

  def last_commented_at
    if topic.comments.present?
      raw "#{last_comment_author} 回复于 #{time_ago_tag(topic.commented_at)} "
    end
  end

  def comments_count
    if topic.comments.present?
      link_to_with_icon topic.comments.count, "fa fa-comment-o", path
    end
  end

  def top
    if topic.is_top
      content_tag(:i, "", class: "fa fa-arrow-circle-up", title: "置顶")
    end
  end

  private

  def last_comment_author
    present(topic.comments.first.author).link_to_with_name
  end
end
