module Api
  module V1
    class GroupsController < ApiController
      before_action :set_group, except: [:index]

      def index
        @groups = Group.visible.page(params[:page]).per(params[:per_page] || 24)
      end

      def show
        @topics = @group.topics.desc(:is_top, :commented_at).limit(params[:topics_limit] || 8)
      end

      private
      def set_group
        @group = Group.find(params[:id])
      end
    end
  end
end
