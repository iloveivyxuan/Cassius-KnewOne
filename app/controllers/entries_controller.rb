class EntriesController < ApplicationController
  layout :explore_layout
  skip_before_action :require_not_blocked

  def show
    @entry = Entry.find(params[:id])
    redirect_to root_path if !@entry.published? && !current_user.try(:role?, :editor)
    redirect_to @entry.external_link if @entry.external_link.present?
  end

  private

  def explore_layout
    (['专访', '评测', '列表'].include? Entry.find(params[:id]).category) ? nil : 'explore'
  end
end
