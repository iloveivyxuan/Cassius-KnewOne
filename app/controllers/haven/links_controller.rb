module Haven
  class LinksController < ApplicationController
    layout 'settings'

    def new
    end

    def create
    end

    def update
      things = params["url"].select { |e| !e.blank? }.map { |u| Thing.find(u.split("/").last) }
      thing_ids = things.map { |t| t.id }
      thing_ids = nil if thing_ids.empty?

      # clear links may be created before
      things.each { |t| t.delete_links }
      # set linked
      things.each { |t| t.update_attributes(link: thing_ids) }

      redirect_to haven_links_path
    end

    def index
      @groups = Thing.linked.all.map { |t| t.link }.uniq
    end

    def show
      @things = Thing.find(params[:id]).link.map { |t| Thing.find(t) }
    end

    def destroy
      Thing.find(params[:id]).delete_links
      redirect_to haven_links_path
    end

  end
end
