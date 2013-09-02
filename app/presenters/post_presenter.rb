# -*- coding: utf-8 -*-
class PostPresenter < ApplicationPresenter
  presents :post
  delegate :title, to: :post

  def path
    #abstract
  end

  def author_tag
    content_tag :div, class: "author" do
      present(@object.author)
        .as_author.concat created_at
    end
  end

  def created_at
    time_ago_tag(@object.created_at)
  end

  def author_avatar(size)
    present(post.author).link_to_with_avatar(size)
  end

  def author_name
    present(post.author).link_to_with_name
  end

  def content
    sanitize(@object.content)
  end

  def summary
    truncate(strip_tags(@object.content), length: 512,
             omission: (link_to_with_icon nil,
                        "icon-ellipsis-horizontal", path, class: "details")
    ).html_safe
  end

  def thing_photo_url(size)
    @object.thing.present? and present(@object.thing).photo_url(size)
  end

  def comments_count
    if @object.comments.present?
      link_to_with_icon @object.comments.count, "icon-comments-alt",
      path, class: "comments_count"
    end
  end

  def share_topic
    user_signed_in? or return
    present(current_user).topic_wrapper(brand)
  end

  def fancied?
    user_signed_in? and @object.fancied?(current_user)
  end

  def fanciers_count
    content_tag :span, @object.fanciers_count, class: "fanciers_count"
  end

end
