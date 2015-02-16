class ReviewPresenter < PostPresenter
  presents :review

  def content
    c = load_post_resources(review.content).gsub /"(http:\/\/#{Settings.image_host}\/.+?)(!.+?)?"/, '"\1!review"'
    review.content_users.each do |u|
      c.gsub! "@#{u.name}", link_to("@#{u.name}", u, data: {'profile-popover' => u.id.to_s})
    end
    sanitize c
  end

  def path
    thing_review_path(review.thing, review)
  end

  def edit_path
    edit_thing_review_path(review.thing, review)
  end

  def cover(size)
    super(size) or present(review.thing).photo(size)
  end

  def share_content(with_link = true)
    if review.author == current_user
      "我在 @KnewOne 发布了 #{review.thing.title} 的测评《#{title}》"
    else
      "推荐 #{share_author_name} 在 #{share_topic} 发布的 #{review.thing.title} 评测《#{title}》"
    end + (with_link ? thing_review_url(review.thing, review, refer: :share) : '')
  end

  def share_pic(size)
    review.cover(size) or thing_photo_url(size)
  end
end
