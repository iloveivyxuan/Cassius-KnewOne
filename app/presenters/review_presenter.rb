# -*- coding: utf-8 -*-
class ReviewPresenter < PostPresenter
  presents :review

  def path
    thing_review_path(review.thing, review)
  end

  def edit_path
    edit_thing_review_path(review.thing, review)
  end

  def share_content
    if review.author == current_user
      "我在#{share_topic} 为 #{review.thing.title} 写了一篇新评测《#{title}》: "
    else
      "我在#{share_topic} 分享了 @#{review.author.name} 对 #{review.thing.title}的评测《#{title}》: "
    end + %Q{“#{summary(40)}” } + thing_review_url(review.thing, review, refer: 'weibo')
  end

  def share_pic(size)
    review.cover(size) or thing_photo_url(size)
  end
end
