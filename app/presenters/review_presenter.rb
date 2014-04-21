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
      content = "我在#{share_topic}为#{review.thing.title}写了一篇新评测: "
    else
      content = "我在#{share_topic}分享了 @#{review.author.name} 对#{review.thing.title}的评测: "
    end

    content += thing_review_url(review.thing, review, refer: 'weibo')
  end
end
