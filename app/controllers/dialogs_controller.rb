class DialogsController < ApplicationController
  load_and_authorize_resource

  def index
    @dialogs = current_user.dialogs
  end

  def create
    receiver = User.where(name: params[:user_name]).first
    receiver and current_user.send_private_message_to receiver, params[:content]
  end
end
