# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  before_filter :trim_param_id

  protect_from_forgery
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to '/403', alert: exception.message
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def store_location(url=nil)
    session[:previous_url] = request.fullpath unless request.fullpath =~ /\/users/
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  private

  def trim_param_id
    params[:id] and params[:id].gsub! /[^\w]$/, ''
  end
end
