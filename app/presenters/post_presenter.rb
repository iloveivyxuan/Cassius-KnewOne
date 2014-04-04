# -*- coding: utf-8 -*-
class PostPresenter < ApplicationPresenter
  presents :post
  delegate :title, :id, :author, to: :post

  def url
    #abstract
  end

  def author_tag
    content_tag :div, class: "author" do
      present(@object.author)
        .as_author.concat created_at
    end
  end

  def created_at(css_class="")
    time_ago_tag(@object.created_at, css_class)
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

  def summary(length = 512)
    strip_tags(@object.content).truncate(length).html_safe
  end

  def thing_photo_url(size)
    @object.thing.present? and present(@object.thing).photo_url(size)
  end

  def comments_count(options = {})
    css = "comments_count #{options.delete(:class)}"
    if @object.comments.present?
      link_to_with_icon @object.comments.count, "fa fa-comments-o",
      url, class: css
    end
  end

  def share_topic
    user_signed_in? or return
    present(current_user).topic_wrapper(brand)
  end

  def votings
    lc, fc = @object.lovers.count, @object.foes.count
    lc <= 0 and return
    content_tag :span, class: "lovers" do
      i = content_tag :i, "", class: "fa fa-plus"
      count = content_tag :small, "#{lc}/#{lc+fc}"
      i.concat count
    end
  end

  def lovers_count
    i = content_tag :i, "", class: "fa fa-plus"
    count = content_tag :span, @object.lovers_count
    i.concat count
  end
end
