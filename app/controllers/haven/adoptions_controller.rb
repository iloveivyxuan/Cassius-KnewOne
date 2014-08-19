module Haven
  class AdoptionsController < ApplicationController
    layout 'settings'

    def index
      @adoptions = Adoption.all
    end

    def approve
      adoption = Adoption.find(params[:id])
      adoption.update_attributes(status: :approved)
      redirect_to :back
    end

    def deny
      adoption = Adoption.find(params[:id])
      adoption.update_attributes(status: :denied)
      redirect_to :back
    end

  end
end
