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
    respond_with @draft
  end

  def update
    @draft = current_user.drafts.find_or_create_by(key: params[:id])

    if params.include?(:review)
      draft_params_review.each { |k, v| @draft["review[#{k.to_sym}]"] = v }
      @draft[:type] = "review"
      @draft[:link] = params[:link]
    end

    @draft.save
    respond_with @draft
  end

  def destroy
    @draft = current_user.drafts.find_by(key: params[:id])
    @draft.destroy
    respond_with @draft
  end

  private

  def draft_params_review
    params.require(:review).permit(:title, :score, :is_top, :content, :author)
  end
end
