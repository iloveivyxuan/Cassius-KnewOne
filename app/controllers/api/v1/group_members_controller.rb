module Api
  module V1
    class GroupMembersController < ApiController
      doorkeeper_for :all, except: [:index]
      before_action :set_resources
      before_action :set_user, except: [:index]
      before_action :check_authorization, :except => [:index]

      def index
        @members = @group.members
      end

      def show
        @member = @group.members.find_by user_id: @user.id
      end

      def create
        @group.members.add @user
        head :no_content
      end

      def destroy
        @group.members.remove @user
        head :no_content
      end

      private
      def set_resources
        @group = Group.find(params[:group_id])
      end

      def set_user
        @user = User.find(params[:id])
      end

      def check_authorization
        head :unauthorized unless @user == current_user
      end
    end
  end
end
