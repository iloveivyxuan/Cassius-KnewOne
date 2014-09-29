module Haven
  class SpecialsController < Haven::ApplicationController
    layout 'settings'
    before_action :set_special, except: [:index, :create, :new]

    def index
      @specials = Special.all.page(params[:page]).desc(:created_at)
    end

    def edit

    end

    def new
      @special = Special.new
      @special.author = current_user
    end

    def update
      @special.update_attributes special_params

      redirect_to edit_haven_special_url(@special)
    end

    def create
      @special = Special.new special_params
      @special.author = current_user if params[:special][:author_id].blank?

      if @special.save
        redirect_to edit_haven_special_url(@special)
      else
        render 'new'
      end
    end

    def destroy
      @special.destroy

      redirect_to haven_specials_url
    end

    private

    def special_params
      params.require(:special).permit!
    end

    def set_special
      @special = Special.find(params[:id])
    end
  end
end
