# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  before_filter :trim_param_id
  protect_from_forgery

  # some bots using some *strange* format to request urls
  # that would trigger missing template exception,
  # so this will reject those request, but you can adjust to your logic
  if Rails.env.production?
    rescue_from ActionView::MissingTemplate do
      head :not_acceptable
    end
  end

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

  def require_admin
    redirect_to '/403' unless current_user and current_user.role?(:admin)
  end

  def redirect_back_or(path, flash = {})
    flash.each_pair do |k,v|
      flash[k] = v
    end
    redirect_to(session.delete(:previous_url) || path)
  end

  helper_method :redirect_back_or

  private

  def trim_param_id
    params[:id] and params[:id].gsub! /[^\w]$/, ''
  end
end
