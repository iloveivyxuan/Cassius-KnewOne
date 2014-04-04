# -*- coding: utf-8 -*-
class ReviewPresenter < PostPresenter
  presents :review

  def url
    thing_review_url(review.thing, review)
  end

  def edit_url
    edit_thing_review_url(review.thing, review)
  end

  def score
    content_tag :div, "", data: {score: review.score}, class: "score"
  end

  def share_content
    if review.author == current_user
      content = "我在#{share_topic}为#{review.thing.title}写了一篇新评测: "
    else
      content = "我在#{share_topic}分享了 @#{review.author.name} 对#{review.thing.title}的评测: "
    end

    content += thing_review_url(review.thing, review, :refer => 'weibo')
  end

  def cover(version = :small)
    if src = review.official_cover(version)
      image_tag src
    end
  end
end
