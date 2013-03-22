class ReviewPresenter < ApplicationPresenter
  presents :review
  delegate :title, to: :review

  def content
    sanitize(raw review.content)
  end

end
