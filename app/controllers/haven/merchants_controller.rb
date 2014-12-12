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
      if @owners
        @merchant = Merchant.create(merchant_params)
        @merchant.group = @group if @group
        @merchant.owners = @owners
      end

      redirect_to haven_merchants_path
    end

    def update
      if @owners
        @merchant.update_attributes(merchant_params)
        @merchant.group = @group if @group
        @merchant.owners = @owners
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
      @owners = params[:merchant][:owner_names].split(/[，,]/).map { |name| User.find_by(name: name) }
    end

    def merchant_params
      params.require(:merchant).slice(:name, :description, :meiqia).permit!
    end
  end
end
