module Api
  module V1
    class GroupsController < ApplicationController
      before_action :set_group, only: [:show]
      def index
        @groups = Group.all
      end

      def show
        @topics = @group.topics.limit(params[:topics_limit] || 8)
      end

      private
      def set_group
        @group = Group.find(params[:id])
      end
    end
  end
end
