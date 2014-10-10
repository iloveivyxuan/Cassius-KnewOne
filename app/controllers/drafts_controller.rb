class DraftsController < ApplicationController
  before_action :require_signed_in

  respond_to :json

  def index
    @drafts = current_user.drafts.desc(:updated_at)
    respond_with @drafts.map(&:hoist_content)
  end

  def show
    @draft = current_user.drafts.where(key: params[:id]).first
    return head :not_found unless @draft
    respond_with @draft.hoist_content
  end

  def update
    @draft = current_user.drafts.find_or_create_by(key: params[:id])
    @draft.update(content: request.raw_post)
    respond_with @draft
  end

  def destroy
    @draft = current_user.drafts.find_by(key: params[:id])
    @draft.destroy
    respond_with @draft
  end
end
