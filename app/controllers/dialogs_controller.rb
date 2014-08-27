class DialogsController < ApplicationController
  before_action :set_dialog, except: [:index, :create]

  def index
    @dialogs = current_user.dialogs.page(params[:page]).per(20)
    @dialogs.each do |dialog|
      dialog.reset
      dialog.newest_message.update(is_new: false)
    end
  end

  def show
    @messages = @dialog.private_messages.page(params[:page]).per(50)
    @messages.where(is_new: true).each {|m| m.update_attribute :is_new, false}
    @dialog.reset
  end

  def create
    receiver = if params[:dialog_user_id].present?
                 User.find params[:dialog_user_id]
               else
                 User.where(name: params[:dialog_user_name]).first
               end

    if receiver
      @message = current_user.send_private_message_to receiver, params[:dialog_content]
    end
  end

  def destroy
    @dialog.destroy
  end

  private

  def set_dialog
    @dialog = current_user.dialogs.find(params[:id])
  end
end
