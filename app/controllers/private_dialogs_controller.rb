class PrivateDialogsController < ApplicationController
  load_and_authorize_resource

  def index
    @dialogs = current_user.private_dialogs
  end

  def create
    receiver = User.find params[:user_id]
    current_user.send_private_message_to receiver, params[:content]
  end
end
