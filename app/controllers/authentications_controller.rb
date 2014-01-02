# encoding: utf-8
class AuthenticationsController < ApplicationController
  prepend_before_action :require_signed_in
  layout 'settings'

  def destroy
    if current_user.can_sign_in_by_password? || current_user.auths.size > 1
      current_user.auths.find(params[:id]).destroy
      redirect_to edit_account_path, flash: {oauth: { status: 'success', text: '解绑成功。' }}
    else
      redirect_to edit_account_path, flash: {oauth: { status: 'success', text: '解绑失败。' }}
    end
  end
end
