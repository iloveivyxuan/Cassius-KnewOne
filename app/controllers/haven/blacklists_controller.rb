module Haven
  class BlacklistsController < Haven::ApplicationController

    layout 'settings'

    def index
      @blacklists = Blacklist.all
    end

    def create
      Blacklist.create(word: params[:blacklist][:word])
      redirect_to haven_blacklists_path
    end

    def destroy
      Blacklist.find(params[:id]).delete
      redirect_to haven_blacklists_path
    end

  end
end
