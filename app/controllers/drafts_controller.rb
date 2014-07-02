class DraftsController < ApplicationController
  before_action :require_signed_in

  respond_to :json

  def index
    @drafts = current_user.drafts
    respond_with @drafts
  end

  def show
    @draft = current_user.drafts.where(key: params[:id]).first

    return head :not_found unless @draft

    content = JSON.parse(@draft.content) rescue {}
    content.merge!(@draft.attributes.except('content'))
    respond_with content
  end

  def update
    @draft = current_user.drafts.find_or_create_by(key: params[:id])
    @draft.update(content: request.body.string)
    respond_with @draft
  end

  def destroy
    @draft = current_user.drafts.find_by(key: params[:id])
    @draft.destroy
    respond_with @draft
  end
end
