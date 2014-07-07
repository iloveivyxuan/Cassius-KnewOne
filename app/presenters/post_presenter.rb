class PostPresenter < ApplicationPresenter
  presents :post
  delegate :title, :id, :author, :content_photos, to: :post

  def path
    #abstract
  end

  def author_tag
    content_tag :div, class: "author" do
      present(@object.author)
        .as_author_with_profile.concat created_at
    end
  end

  def created_at(css_class="")
    time_ago_tag(@object.created_at, css_class)
  end

  def author_avatar(size = :small, options = {})
    present(post.author).link_to_with_avatar(size, {}, options)
  end

  def author_name
    present(post.author).link_to_with_popoverable_name
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
      path, class: css
    end
  end

  def share_topic
    user_signed_in? or return
    present(current_user).topic_wrapper(brand)
  end

  def lovers_count
    i = content_tag :i, "", class: "fa fa-plus"
    count = content_tag :span, @object.lovers_count
    i.concat count
  end

  def cover(version = :small)
    if src = post.cover(version)
      image_tag src
    end
  end

  def videos
    @object.content.scan(%r{<iframe .+?></iframe>}).map(&:html_safe)
  end

  def score
    if post.try(:score).present? and post.score > 0
      content_tag :div, "", data: {score: post.score}, class: "score"
    end
  end

  def share_content
  end

  def share_pic(size)
  end

  def share_author_name
    if @object.author.current_auth
      '@' + @object.author.current_auth.name
    else
      @object.author.name
    end
  end

  def link_to_share(klass = '')
    link_to_with_icon "分享", "fa fa-share-alt",
    user_signed_in? ? "#share_modal" : "#login-modal",
    title: "分享", class: "#{klass} share_btn track_event",
    data: {
      toggle: 'modal',
      content: share_content,
      pic: share_pic(:huge),
      preview_pic: share_pic(:small),
      category: "share_internal_ready",
      action: "share_internal_ready_#{post.class.to_s.downcase}",
      label: path
    }
  end
end
