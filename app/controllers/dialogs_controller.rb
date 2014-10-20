class DialogsController < ApplicationController
  prepend_before_action :require_signed_in
  before_action :set_dialog, except: [:index, :create, :readall]

  def index
    @dialogs = current_user.dialogs.page(params[:page]).per(20)
    @dialogs.each do |dialog|
      dialog.reset
      dialog.newest_message.update(is_new: false)
    end
  end

  def show
    @messages = @dialog.private_messages.page(params[:page]).per(50)
    @messages.update_all(is_new: false)
    @dialog.reset
  end

  def readall
    current_user.dialogs.gt(unread_count: 0).each do |dialog|
      dialog.private_messages.update_all(is_new: false)
      dialog.reset
    end
    redirect_to dialogs_path
  end

  def create
    receiver = if params[:dialog_user_id].present?
                 User.find params[:dialog_user_id]
               else
                 User.where(name: params[:dialog_user_name]).first
               end

    if receiver
      @message = current_user.send_private_message_to receiver, params[:dialog_content]
      if session[:previous_url] =~ /things\/([0-9a-z-]*)/
        result = /things\/([0-9a-z-]*)/.match "/things/iqunix-pad-lu-he-jin-shu-biao-dian"
        thing = Thing.where(slugs: "bong-ii").first
        current_user.log_activity :invite_review, receiver, source: thing, visible: false if thing
      end
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
