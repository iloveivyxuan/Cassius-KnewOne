module Api
  module V1
    class TopicsController < ApiController
      before_action :set_resources
      before_action :set_topic, except: [:index, :create]
      before_action :check_authorization, only: [:update, :destroy]
      doorkeeper_for :all, except: [:index, :show]

      def index
        @topics = @group.topics.desc(:is_top, :commented_at).page(params[:page]).per(params[:per_page])
      end

      def show
      end

      def create
        @topic = @group.topics.build topic_params.merge(author: current_user)

        if @topic.save
          current_user.log_activity :new_topic, @topic, source: @topic.group
          render action: 'show', status: :created, location: [:api, :v1, @group, @topic]
        else
          render json: @topic.errors, status: :unprocessable_entity
        end
      end

      def update
        if @topic.update(topic_params)
          head :no_content
        else
          render json: @topic.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @topic.destroy
        current_user.log_activity :delete_topic, @topic, visible: false

        head :no_content
      end

      private
      def topic_params
        params.require(:topic).permit :title, :content
      end

      def set_resources
        @group = Group.find(params[:group_id])
      end

      def set_topic
        @topic = @group.topics.find(params[:id])
      end

      def check_authorization
        head :unauthorized unless @topic.author == current_user
      end
    end
  end
end
