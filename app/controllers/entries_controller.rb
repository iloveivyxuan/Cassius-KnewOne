class EntriesController < ApplicationController
  layout 'explore'
  skip_before_action :require_not_blocked

  def show
    @entry = Entry.find(params[:id])
    redirect_to root_path if !@entry.published? && !current_user.try(:role?, :editor)
    redirect_to @entry.external_link if @entry.external_link.present?
  end
end
