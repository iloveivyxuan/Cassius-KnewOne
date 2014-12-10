class EntriesController < ApplicationController
  layout :explore_layout
  skip_before_action :require_not_blocked

  def show
    @entry = Entry.find(params[:id])
    return redirect_to root_path if !@entry.published? && !current_user.try(:role?, :editor)
    return redirect_to @entry.external_link if @entry.external_link.present?
    respond_to do |format|
      format.wechat do
        render wechat: @entry, layout: false, content_type: 'text/html'
      end
    end
  end

  private

  def explore_layout
    (['专访', '评测', '列表'].include? Entry.find(params[:id]).category) ? nil : 'explore'
  end
end
