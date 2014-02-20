module Api
  module V1
    module ReviewsHelper
      def content_summary(review, length = 512)
        strip_tags(sanitize(review.content)).truncate(length).html_safe
      end
    end
  end
end
