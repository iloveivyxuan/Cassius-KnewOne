module Haven
  class AdoptionsController < ApplicationController
    layout 'settings'

    def index
      @adoptions ||= Adoption.all

      if params[:thing]
        thing = Thing.find params[:thing]
        @adoptions = @adoptions.where(:thing => thing)
      end
      if params[:status]
        @adoptions = @adoptions.where(:status => params[:status].to_sym)
      end
      @adoptions
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

    def one_click_deny
      Thing.find(params[:adoption]).adoptions.each do |a|
        if a.status == :waiting
          a.status = :denied
          a.save
        end
      end
      redirect_to :back
    end

  end
end
