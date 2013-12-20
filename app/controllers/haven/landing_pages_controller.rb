#encoding: utf-8
module Haven
  class LandingPagesController < ApplicationController
    before_action :set_landing_page, only: [:show, :edit, :update, :destroy]
    layout 'settings'

    def index
      @landing_pages = LandingPage.all
    end

    def show
      render layout: 'home'
    end

    def new
      @landing_page = LandingPage.new
    end

    def edit
    end

    def create
      @landing_page = LandingPage.new(landing_page_params)

      if @landing_page.save
        redirect_to haven_landing_page_path(@landing_page), notice: 'Landing page was successfully created.'
      else
        render action: 'new'
      end
    end

    def update
      if @landing_page.update(landing_page_params)
        redirect_to haven_landing_page_path(@landing_page), notice: 'Landing page was successfully updated.'
      else
        render action: 'edit'
      end
    end

    def destroy
      @landing_page.destroy

      redirect_to haven_landing_pages_url
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_landing_page
      @landing_page = LandingPage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def landing_page_params
      params.require(:landing_page).permit!
    end
  end
end
