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
    topic.comments.present? or return
    content_tag :span, class: "commented_at" do
      raw "最后由#{last_comment_author}于#{time_ago_tag(topic.commented_at)}回复"
    end
  end

  def comments_count
    if topic.comments.present?
      link_to topic.comments.count, path, class: "badge"
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
