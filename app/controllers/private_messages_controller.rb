class PrivateMessagesController < ApplicationController
  respond_to :json
  load_and_authorize_resource :dialog
  load_and_authorize_resource :private_message, through: :dialog

  def destroy
    @private_message.destroy
  end
end
