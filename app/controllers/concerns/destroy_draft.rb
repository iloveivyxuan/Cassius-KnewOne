module DestroyDraft
  extend ActiveSupport::Concern

  included do
    after_action :destroy_draft, only: [:create, :update]
  end

  private

  def destroy_draft
    return unless user_signed_in? && params[:draft].try(:[], :key)
    return if response.status >= 400
    current_user.drafts.where(key: params[:draft][:key]).destroy
  end
end
