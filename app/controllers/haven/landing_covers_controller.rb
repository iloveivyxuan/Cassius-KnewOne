#encoding: utf-8
module Haven
  class LandingCoversController < ApplicationController
    before_action :set_landing_cover, only: [:show, :edit, :update, :destroy]
    layout 'settings'

    def index
      @landing_covers = LandingCover.all
    end

    def show
      render layout: 'home'
    end

    def new
      @landing_cover = LandingCover.new
    end

    def edit
    end

    def create
      @landing_cover = LandingCover.new(landing_cover_params)

      if @landing_cover.save
        redirect_to haven_landing_covers_url, notice: 'Landing cover was successfully created.'
      else
        render action: 'new'
      end
    end

    def update
      if @landing_cover.update(landing_cover_params)
        redirect_to haven_landing_covers_url, notice: 'Landing cover was successfully updated.'
      else
        render action: 'edit'
      end
    end

    def destroy
      @landing_cover.destroy

      redirect_to haven_landing_covers_url
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_landing_cover
      @landing_cover = LandingCover.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def landing_cover_params
      params.require(:landing_cover).permit!
    end
  end
end
