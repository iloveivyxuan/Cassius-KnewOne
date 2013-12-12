# -*- coding: utf-8 -*-
class SessionsController < Devise::SessionsController
  before_action only: [:new] do
    session[:previous_url] = request.fullpath
  end
end
