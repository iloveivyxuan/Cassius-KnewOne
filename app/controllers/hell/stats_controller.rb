module Hell
  class StatsController < ApplicationController
    def contents_product
      render_error :missing_field, 'missing flags' if params[:flags].blank?

      @result = {
          generated_at: Date.today,
          total_reviews_count: Review.where(:created_at.gte => 7.days.ago).size,
          total_things_count: Review.where(:created_at.gte => 7.days.ago).size,
          total_feelings_count: Feeling.where(:created_at.gte => 7.days.ago).size,
          total_topics_count: Topic.where(:created_at.gte => 7.days.ago).size,
          total_comments_count: Comment.where(:created_at.gte => 7.days.ago).size,
          flags: {}
      }

      params[:flags].split(',').each do |f|
        user_ids = User.where(:flags => f).map &:id

        @result[:flags][f] = {
            reviews_count: Review.where(:created_at.gte => 7.days.ago, :author_id.in => user_ids).size,
            things_count: Thing.where(:created_at.gte => 7.days.ago, :author_id.in => user_ids).size,
            feelings_count: Feeling.where(:created_at.gte => 7.days.ago, :author_id.in => user_ids).size,
            topics_count: Topic.where(:created_at.gte => 7.days.ago, :author_id.in => user_ids).size,
            comments_count: Comment.where(:created_at.gte => 7.days.ago, :author_id.in => user_ids).size
        }
      end

      render json: @result
    end
  end
end
