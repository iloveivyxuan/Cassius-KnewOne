module Haven
  class ThingListBackgroundsController < Haven::ApplicationController
    layout 'settings'

    def index
    end

    def edit
      @thing_list_background = ThingListBackground.find(params[:id])
    end

    def create
      ThingListBackground.create(thing_list_background_params)
      redirect_to haven_thing_list_backgrounds_url
    end

    def update
      ThingListBackground.find(params[:id]).update(thing_list_background_params)

      respond_to do |format|
        format.html { redirect_to haven_thing_list_backgrounds_url }
        format.json { head :no_content }
      end
    end

    def destroy
      if ThingListBackground.count > 1
        ThingListBackground.find(params[:id]).destroy
      end

      redirect_to haven_thing_list_backgrounds_url
    end

    private

    def thing_list_background_params
      params.require(:thing_list_background).permit(:image, :order, :hidden)
    end
  end
end
