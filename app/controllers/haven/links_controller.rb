module Haven
  class LinksController < ApplicationController
    layout 'settings'

    def new
    end

    def create
    end

    def update
      things = params["url"].select { |e| !e.blank? }.map { |u| Thing.find(u.split("/").last) }
      thing_ids = things.map { |t| t.id.to_s }

      # associate categories & shop url.
      thing_categories = []
      things.each { |t| thing_categories += t.categories }
      thing_categories.uniq!
      thing_shop = things.map(&:shop).select { |t| !t.blank? }.first

      # clear links may be created before
      things.each { |t| t.delete_links }
      # set linked
      things.each do |t|
        t.links = thing_ids
        t.categories = thing_categories
        t.shop = thing_shop if t.shop.blank?
        t.save!
      end

      redirect_to haven_links_path
    end

    def index
      @groups = Thing.linked.all.map { |t| t.links }.uniq
    end

    def show
      @things = Thing.find(params[:id]).links.map { |t| Thing.find(t) }
    end

    def destroy
      Thing.find(params[:id]).delete_links
      redirect_to haven_links_path
    end

  end
end
