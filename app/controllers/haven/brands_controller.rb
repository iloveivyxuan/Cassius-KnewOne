module Haven
  class BrandsController < Haven::ApplicationController
    layout 'settings'
    before_action :set_brand, only: [:edit, :destroy, :update]
    before_action :store_location, only: [:index]

    def index
      if params[:brand_name]
        brand_regex = /#{params[:brand_name].strip}/i
        @brands = Brand.or({ zh_name: brand_regex }, { en_name: brand_regex })
      elsif params[:filter]
        case params[:filter]
        when 'things_count'
          @brands = Brand.desc(:things_count)
        when 'created_at'
          @brands = Brand.desc(:created_at)
        when 'updated_at'
          @brands = Brand.desc(:updated_at)
        when 'no_description'
          @brands = Brand.where(description: "")
        when 'no_country'
          @brands = Brand.asc(:country)
        end
      else
        @brands = Brand.all.desc(:things_size)
      end
      @brands = @brands.page(params[:page]).per(20)
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
