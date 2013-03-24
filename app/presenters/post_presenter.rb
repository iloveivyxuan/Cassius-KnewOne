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

  def summary
    truncate strip_tags(raw @object.content), length: 300
  end

  def comments_count
    @object.comments.count <= 0 and return
    content_tag :span, class: "comments" do
      link_to_with_icon @object.comments.count, "icon-comments-alt", path
    end
  end

end
