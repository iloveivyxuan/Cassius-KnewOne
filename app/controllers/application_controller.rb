# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  before_action :trim_param_id
  protect_from_forgery

  prepend_before_action do
    logger.info '------ session -------'
    logger.info session.to_hash
    logger.info '----------------------'
    logger.info request.host
    logger.info request.headers['Origin']
    logger.info '----------------------'
  end

  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :store_location, only: [:index, :show]

  after_action :cors_set_access_control_headers

  prepend UserRoutesHelper
  helper UserRoutesHelper

  def default_url_options
    {subdomain: nil}
  end

  # some bots using some *strange* format to request urls
  # that would trigger missing template exception,
  # so this will reject those request, but you can adjust to your logic
  if Rails.env.production?
    rescue_from ActionView::MissingTemplate do
      head :not_acceptable
    end

    # rails 4 will raise this exception when action can not respond request format
    rescue_from ActionController::UnknownFormat do
      head :not_acceptable
    end

    rescue_from ArgumentError do
      head :bad_request
    end

    rescue_from EncodingError do
      head :bad_request
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    if request.format == Mime::HTML
      session[:previous_url] = request.fullpath
    end

    redirect_to '/403', alert: exception.message
  end

  def redirect_stored_or(path, flash = {})
    flash.each_pair do |k, v|
      flash[k] = v
    end
    redirect_to(session.delete(:previous_url) || path, flash)
  end

  def redirect_back_or(path, flash = {})
    flash.each_pair do |k, v|
      flash[k] = v
    end
    url = params[:redirect_from].present? ? params[:redirect_from] : path # Avoiding querystring like redirect_from=&
    redirect_to(url, flash)
  end

  helper_method :redirect_stored_or, :redirect_back_or

  protected

  def require_signed_in
    return if user_signed_in?

    if request.format == Mime::HTML
      session[:previous_url] = request.fullpath

      redirect_to '/403'
    else
      authenticate_user!
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).concat [:location, :name, :description]
    devise_parameter_sanitizer.for(:account_update).concat [:location, :name, :description]
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def store_location(url=nil)
    return unless request.format == Mime::HTML

    session[:previous_url] = request.fullpath
  end

  def after_sign_in_path_for(resource)
    params[:redirect_from] || session.delete(:previous_url) || root_url || super
  end

  def require_admin
    redirect_to '/403' unless current_user and current_user.role?(:admin)
  end

  def allow_iframe_load
    response.headers['X-XSS-Protection'] = '0'
  end

  def subdomain?
    @_is_subdomain ||= request.headers['Origin'] && /^.+\.#{Settings.host}$/ =~ request.headers['Origin']
  end

  private

  def trim_param_id
    params[:id] and params[:id].gsub! /[^\w]$/, ''
  end

  # FROM: http://www.tsheffler.com/blog/?p=428
  # For all responses in this controller, return the CORS access control headers.
  def cors_set_access_control_headers
    if subdomain?
      headers['Access-Control-Max-Age'] = '1728000'
      headers['Access-Control-Allow-Origin'] = request.headers['Origin']
      headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
      headers['Access-Control-Request-Method'] = '*'
      headers['Access-Control-Allow-Credentials'] = 'true'
      headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization, X-CSRF-Token'
    end
  end
end
