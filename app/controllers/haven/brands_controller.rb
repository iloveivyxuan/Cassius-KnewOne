module Haven
  class BrandsController < Haven::ApplicationController
    layout 'settings'
    before_action :set_brand, only: [:destroy]

    def index
      @brands = Brand.all
    end

    def destroy
      @brand.things.each do |thing|
        thing.brand = nil
        thing.save
      end
      @brand.destroy
      redirect_to haven_brands_path
    end

    private

    def set_brand
      @brand = Brand.find params[:id]
    end

  end
end
