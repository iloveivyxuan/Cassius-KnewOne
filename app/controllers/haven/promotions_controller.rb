module Haven
  class PromotionsController < Haven::ApplicationController
    before_action :set_promotion, only: [:show, :edit, :update, :destroy]
    layout 'settings'

    def index
      @promotions = Promotion.all
    end

    def new
      @promotion = Promotion.new
    end

    def edit
    end

    def create
      @promotion = Promotion.new(promotion_params)

      if @promotion.save
        redirect_to haven_promotions_path, notice: 'Promotion was successfully created.'
      else
        render action: 'new'
      end
    end

    def update
      if @promotion.update(promotion_params)
        redirect_to haven_promotions_path, notice: 'Promotion was successfully updated.'
      else
        render action: 'edit'
      end
    end

    def destroy
      @promotion.destroy

      redirect_to haven_promotions_url
    end

    private

    def set_promotion
      @promotion = Promotion.find(params[:id])
    end

    def promotion_params
      params.require(:promotion).permit!
    end
  end
end
