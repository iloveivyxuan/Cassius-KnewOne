# -*- coding: utf-8 -*-
class TopicPresenter < PostPresenter
  presents :topic

  def path
    [topic.group, topic]
  end

  def cover(version = :small)
    if src = topic.official_cover(version)
      image_tag src
    end
  end

  def edit_path
    [:edit, topic.group, topic]
  end

  def last_commented_at
    if topic.comments.present?
      raw "#{last_comment_author} 回复于 #{time_ago_tag(topic.commented_at)} "
    else
      time_ago_tag topic.created_at
    end
  end

  def comments_count
    if topic.comments.present?
      link_to_with_icon topic.comments.count, "fa fa-comment-o", path
    end
  end

  def top
    if topic.is_top
      content_tag(:i, "", class: "fa fa-arrow-up", title: "置顶")
    end
  end

  def group
    link_to topic.group.name, topic.group
  end

  def share_content
    if topic.author == current_user
      content = "我在#{share_topic}发起了话题：#{topic.title}"
    else
      content = "我在#{share_topic}分享了 @#{topic.author.name} 的话题： #{topic.title} "
    end

    content + group_topic_url(topic.group, topic, :refer => 'weibo')
  end

  private

  def last_comment_author
    present(topic.comments.first.author).link_to_with_name
  end
end
