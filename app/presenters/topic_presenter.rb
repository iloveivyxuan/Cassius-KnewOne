class TopicPresenter < PostPresenter
  presents :topic

  def path
    group_topic_path(topic.group, topic)
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
      link_to_with_icon topic.comments_count, "fa fa-comment-o", path
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
      "我在#{share_topic}发起了话题《#{title}》: "
    else
      "分享 #{share_author_name} 的 #{share_topic} 话题《#{title}》: "
    end + group_topic_url(topic.group, topic, refer: 'weibo')
  end

  def share_pic(size)
    topic.cover(size) or topic.group.avatar.url(size)
  end

  private

  def last_comment_author
    present(topic.comments.first.author).link_to_with_popoverable_name
  end
end
