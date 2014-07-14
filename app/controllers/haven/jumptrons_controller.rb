module Haven
  class JumptronsController < ApplicationController
    layout 'settings'

    def new
    end

    def index
      @jumptrons = Jumptron.order_by([:created_at, :desc]).page params[:page]
    end

    def edit
      @jumptron = Jumptron.find(params[:id])
    end

    def update
      @jumptron = Jumptron.find(params[:id])
      if @jumptron.update(jumptron_params)
        set_other_jumptron_default_false(@jumptron) if @jumptron.default
        redirect_to haven_jumptrons_url
      else
        render 'edit'
      end
    end

    def create
      jumptron = Jumptron.new(jumptron_params)
      if jumptron.save
        set_other_jumptron_default_false(jumptron) if jumptron.default
        redirect_to haven_jumptrons_url
      else
        render 'new'
      end
    end

    def destroy
      Jumptron.find(params[:id]).destroy
      redirect_to haven_jumptrons_url
    end

    private

    def jumptron_params
      params.require(:jumptron).permit(:image, :alt, :href, :default)
    end

    def set_other_jumptron_default_false(j)
      jumptrons = Jumptron.where(default: true)
      jumptrons.each { |ju| ju.update_attributes(default: false) if ju != j }
    end

  end
end
