module DestroyDraftAfterCreate
  extend ActiveSupport::Concern

  included do
    after_action :destroy_draft, only: :create
  end

  private

  def destroy_draft
    return unless user_signed_in? && params[:draft].try(:[], :key)
    current_user.drafts.where(key: params[:draft][:key]).destroy
  end
end
