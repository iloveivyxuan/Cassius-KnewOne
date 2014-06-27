class DraftsController < ApplicationController
  before_action :require_signed_in

  respond_to :json

  def index
    @drafts = current_user.drafts
    respond_with @drafts
  end

  def show
    @draft = current_user.drafts.find_by(key: params[:id])
    respond_with @draft
  end

  def update
    @draft = current_user.drafts.find_or_create_by(key: params[:id])
    @draft.update(draft_params)
    respond_with @draft
  end

  def destroy
    @draft = current_user.drafts.find_by(key: params[:id])
    @draft.destroy
    respond_with @draft
  end

  private

  def draft_params
    params.require(:draft).permit(:content)
  end
end
