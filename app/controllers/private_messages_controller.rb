class PrivateMessagesController < ApplicationController
  prepend_before_action :require_signed_in
  respond_to :json

  before_action :set_private_message

  def destroy
    @private_message.destroy
  end

  private

  def set_private_message
    @dialog = current_user.dialogs.find(params[:dialog_id])
    @private_message = @dialog.private_messages.find(params[:id])
  end
end
