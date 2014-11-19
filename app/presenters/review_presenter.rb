class ReviewPresenter < PostPresenter
  presents :review

  def path
    thing_review_path(review.thing, review)
  end

  def edit_path
    edit_thing_review_path(review.thing, review)
  end

  def cover(size)
    super(size) or present(review.thing).photo(size)
  end

  def share_content
    if review.author == current_user
      "#晒牛玩#我刚刚动手玩了下 #{review.thing.title} ，在剁手站 #{share_topic} 写了一篇体验测评《#{title}》，小伙伴快来围观 →_→： #{thing_review_url(review.thing, review, refer: :share)}"
    else
      "推荐 @#{share_author_name} 在 #{share_topic} 发布的 #{review.thing.title} 评测《#{title}》：#{thing_review_url(review.thing, review, refer: :share)}"
    end
  end

  def share_pic(size)
    review.cover(size) or thing_photo_url(size)
  end
end
