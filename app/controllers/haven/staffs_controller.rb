module Haven
  class StaffsController < Haven::ApplicationController
    layout 'settings'
    before_action :authenticate_admin

    def index
      role = params[:filter].try :to_sym
      @users = if User::ROLES.include? role
                 User.try role
               else
                 User.staff
               end.page params[:page]
    end

    def show
      @user = User.find(params[:id])
    end

    def update
      user = User.find(params[:id])
      params[:user][:role] = params[:user][:role].first

      user.update(user_params)

      redirect_back_or haven_staffs_path
    end

    def role
      redirect_to :action => 'show', :id => User.find(params[:role][:staff]).id
    end

    private

    def user_params
      params.require(:user).permit!
    end

    def authenticate_admin
      raise ActionController::RoutingError.new('Not Found') unless current_user.role? :admin
    end

  end
end
