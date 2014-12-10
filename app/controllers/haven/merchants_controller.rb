module Haven
  class MerchantsController < Haven::ApplicationController
    layout 'settings'
    before_action :set_merchant, except: [:index, :new, :create]
    before_action :set_user_and_group, only: [:create, :update]

    def index
      @merchants = Merchant.all
      @merchants = @merchants.page params[:page]
    end

    def new
    end

    def edit
    end

    def show
    end

    def create
      if @group && @user
        @merchant = Merchant.create(name: params[:merchant][:name], description: params[:merchant][:description])
        @user.merchant = @merchant
        @merchant.group = @group
      end

      redirect_to haven_merchants_path
    end

    def update
      if @group && @user
        @merchant.update_attributes(name: params[:merchant][:name], description: params[:merchant][:description])
        @user.merchant = @merchant
        @merchant.group = @group
      end

      redirect_to haven_merchants_path
    end

    def destroy
      @merchant.delete
      redirect_to haven_merchants_path
    end

    private

    def set_merchant
      @merchant = Merchant.find params[:id]
    end

    def set_user_and_group
      @group = Group.where(id: params[:merchant][:group_id]).first
      @user = User.where(name: params[:merchant][:user_name]).first
    end

    def merchant_params
      params.require(:merchant).permit!
    end
  end
end
