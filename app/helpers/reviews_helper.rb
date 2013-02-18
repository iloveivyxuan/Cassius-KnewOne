# -*- coding: utf-8 -*-
module ReviewsHelper
  def review_share_content(review)
    if review.author == current_user
      content = "我在##{brand}#为#{review.thing.title}写了一篇新评测: "
    else
      content = "##{brand}#，分享 @#{review.author.current_auth.nickname} 对#{review.thing.title}的评测: "
    end

    content += thing_review_url(review.thing, review)
  end
end
