module Haven
  class BrandsController < Haven::ApplicationController
    layout 'settings'
    before_action :set_brand, only: [:edit, :destroy, :update]
    before_action :store_location, only: [:index]

    def index
      if params[:brand_name]
        brand_regex = /#{params[:brand_name].strip}/i
        @brands = Brand.or({ zh_name: brand_regex }, { en_name: brand_regex }).page(params[:page]).per(20)
      else
        @brands = Brand.all.desc(:things_size).page(params[:page]).per(20)
      end
    end

    def edit
    end

    def update
      if @brand.update brand_params
        redirect_to session[:previous_url]
      else
        redirect_to :back
      end
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

    def brand_params
      params.require(:brand).permit!
    end

    def set_brand
      @brand = Brand.find params[:id]
    end

    def store_location
      session[:previous_url] = request.fullpath
    end

  end
end
