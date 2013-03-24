# -*- coding: utf-8 -*-
class ReviewPresenter < PostPresenter
  presents :review

  def path
    thing_review_path(review.thing, review)
  end

  def edit_path
    edit_thing_review_path(review.thing, review)
  end

  def score
    content_tag :div, "", data: {score: review.score}, class: "score"
  end

  def summary
    raw super.concat link_to_with_icon "", "icon-file-alt", path, class: "details"
  end

  def lovers_count
    lc, fc = review.lovers.count, review.foes.count
    lc <= 0 and return
    content_tag :span, class: "lovers" do
      i = content_tag :i, "", class: "icon-thumbs-up"
      count = content_tag :small, "#{lc}/#{lc+fc}"
      i.concat count
    end
  end

  def thing_photo_url(size)
    present(review.thing).photo_url(size)
  end

  def share_content
    user_signed_in? or return
    topic = present(current_user).topic_wrapper(brand)
    if review.author == current_user
      content = "我在#{topic}为#{review.thing.title}写了一篇新评测: "
    else
      content = "我在#{topic}分享了 @#{review.author.current_auth.nickname} 对#{review.thing.title}的评测: "
    end

    content += thing_review_url(review.thing, review)
  end
end
