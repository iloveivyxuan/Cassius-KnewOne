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
        when 'things_size'
          @brands = Brand.desc(:things_size)
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
      respond_to do |format|
        format.html do
          @brands = @brands.page(params[:page]).per(20)
        end
        format.csv do
          lines = [%w(品牌名(中文) 品牌名(英文) 链接 国家 描述 产品数)]
          @brands.each do |brand|
            lines << [
                      brand.zh_name,
                      brand.en_name,
                      '=HYPERLINK("' + brand_things_url(brand.id.to_s) + '")',
                      brand.country,
                      brand.description,
                      brand.things_size
                     ]
          end
                    col_sep = (params[:platform] == 'numbers') ? ',' : ';'

          csv = CSV.generate :col_sep => col_sep do |csv|
            lines.each { |l| csv<< l }
          end

          filename = "品牌导出 - #{Time.now}.csv"

          if params[:platform] != 'numbers'
            send_data csv.encode('gb2312', :replace => ''), :filename => filename
          else
            send_data csv, :replace => '', :filename => filename
          end
        end
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

    def clear
      Brand.where(things_size: 0).delete_all
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
