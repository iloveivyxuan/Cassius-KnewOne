#encoding: utf-8
class EntriesController < ApplicationController
  layout 'explore'

  def show
    @entry = Entry.find(params[:id])
  end
end
