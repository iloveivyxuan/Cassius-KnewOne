module Haven
  class EntriesController < ApplicationController
    layout 'settings'
    before_action :set_entry, except: [:index, :create, :new]

    def index
      @entries = Entry.all.page params[:page]
    end

    def edit

    end

    def new
      @entry = Entry.new
    end

    def update
      @entry.update_attributes entry_params

      redirect_to haven_entries_url
    end

    def create
      entry = Entry.new entry_params

      if entry.save
        redirect_to haven_entries_url
      else
        render 'new'
      end
    end

    def destroy
      @entry.destroy

      redirect_to haven_entries_url
    end

    private

    def entry_params
      params.require(:entry).permit!
    end

    def set_entry
      @entry = Entry.find(params[:id])
    end
  end
end
