class PostPresenter < ApplicationPresenter
  presents :post
  delegate :title, to: :post

  def path
    #abstract
  end

  def author
    content_tag :div, class: "author" do
      present(@object.author)
        .as_author.concat time_ago_tag(@object.created_at)
    end
  end

  def content
    sanitize(raw @object.content)
  end

  def thing_photo_url(size)
    @object.thing.present? and present(@object.thing).photo_url(size)
  end

  def summary
    truncate strip_tags(raw @object.content), length: 300
  end

  def comments_count
    content_tag :span, class: "comments" do
      c = @object.comments.count
      link_to_with_icon (c > 0 ? c : ""), "icon-comments-alt", path
    end
  end

  def share_topic
    user_signed_in? or return
    present(current_user).topic_wrapper(brand)
  end

end
