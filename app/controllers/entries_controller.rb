#encoding: utf-8
class EntriesController < ApplicationController
  layout 'explore'

  def show
    @entry = Entry.find(params[:id])
    redirect_to root_path if !@entry.published? && !current_user.try(:role?, :editor)
    redirect_to @entry.external_link if @entry.external_link.present?
  end
end
