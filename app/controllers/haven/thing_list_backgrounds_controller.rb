module Haven
  class ThingListBackgroundsController < Haven::ApplicationController
    layout 'settings'

    def index
    end

    def create
      ThingListBackground.create(thing_list_background_params)
      redirect_to haven_thing_list_backgrounds_url
    end

    def update
      ThingListBackground.find(params[:id]).update(thing_list_background_params)
      head :no_content
    end

    def destroy
      ThingListBackground.find(params[:id]).destroy
      redirect_to haven_thing_list_backgrounds_url
    end

    private

    def thing_list_background_params
      params.require(:thing_list_background).permit(:image)
    end
  end
end
