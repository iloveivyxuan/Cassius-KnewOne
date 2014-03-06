class DialogsController < ApplicationController
  load_and_authorize_resource

  def index
    @dialogs = current_user.dialogs.page(params[:page]).per(20)
  end

  def show
    @messages = @dialog.private_messages.page(params[:page]).per(50)
  end

  def create
    receiver = User.where(name: params[:user_name]).first
    receiver and current_user.send_private_message_to receiver, params[:content]
  end
end
