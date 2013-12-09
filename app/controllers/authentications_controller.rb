# encoding: utf-8
class AuthenticationsController < ApplicationController
  prepend_before_filter :authenticate_user!
  layout 'settings'

  def destroy
    if (current_user.initial? && current_user.auths.size > 1) || current_user.normal?
      current_user.auths.find(params[:id]).destroy
      redirect_to edit_account_path, flash: {oauth: 'success'}
    else
      redirect_to edit_account_path, flash: {oauth: 'fail'}
    end
  end
end
