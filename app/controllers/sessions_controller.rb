# -*- coding: utf-8 -*-
class SessionsController < Devise::SessionsController
  layout 'oauth'

  before_action only: [:new] do
    session[:previous_url] = request.fullpath
  end
end
