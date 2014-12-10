module Haven
  class MerchantsController < Haven::ApplicationController
    layout 'settings'
    before_action :set_merchant, except: [:index, :new, :create]

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
      @merchant = Merchant.create(name: params[:merchant][:name], description: params[:merchant][:description])
      @merchant.group = Group.find(params[:merchant][:group_id])

      redirect_to haven_merchants_path
    end

    def update
      @merchant.update_attributes(name: params[:merchant][:name], description: params[:merchant][:description])

      @merchant.group = Group.find(params[:merchant][:group_id])
      @merchant.user = User.find_by(name: params[:merchant][:user_name])

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

    def merchant_params
      params.require(:merchant).permit!
    end
  end
end
