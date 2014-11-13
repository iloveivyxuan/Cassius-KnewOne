class ApplicationController < ActionController::Base
  before_action :logging
  before_action :trim_param_id
  protect_from_forgery

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_variant
  after_action :store_location, only: [:index, :show]
  prepend_before_action :require_not_blocked, except: :blocked
  before_action :auto_login_in_wechat


  if Rails.env.production?
    # some bots using some *strange* format to request urls
    # that would trigger missing template exception,
    # so this will reject those request, but you can adjust to your logic
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

    rescue_from ActionController::InvalidCrossOriginRequest do
      head :bad_request
    end

    rescue_from ActionController::ParameterMissing do
      head :bad_request
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html do
        if request.format == Mime::HTML
          session[:previous_url] = request.fullpath
        end

        redirect_to '/403', alert: exception.message
      end

      format.json do
        head :forbidden
      end

      format.js do
        head :forbidden
      end
    end
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

  # get mentioned users
  # eg. "@Liam hello world cc @Syn" will get @Liam and @Syn
  def mentioned_users(content)
    User.in(name: content.scan(/@(\S+)/).flatten).to_a
  end

  protected

  def require_signed_in
    return if current_user

    if request.format == Mime::HTML
      session[:previous_url] = request.fullpath

      redirect_to '/403'
    else
      head :forbidden
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
    return if request.format != Mime::HTML || request.xhr? || !request.get?

    session[:previous_url] = request.fullpath
  end

  def after_sign_in_path_for(resource)
    params[:redirect_from] || session.delete(:previous_url) || root_path || super
  end

  def require_admin
    redirect_to '/403' unless current_user and current_user.role?(:admin)
  end

  def allow_iframe_load
    response.headers['X-XSS-Protection'] = '0'
  end

  def require_not_blocked
    if user_signed_in? && current_user.blocked?
      redirect_to blocked_path
    end
  end

  def bind_omniauth
    if session[:omniauth].present? && user_signed_in?
      if a = current_user.auths.where(provider: session[:omniauth][:provider]).first
         a.update session[:omniauth]
      else
        current_user.auths<< Auth.new(session[:omniauth])
        current_user.update_from_omniauth(session[:omniauth])
      end

      session.delete :omniauth
    end
  end

  def auto_login_in_wechat
    if browser.wechat? && !user_signed_in?
      redirect_to user_omniauth_authorize_path(:wechat, state: "auto_login||#{request.fullpath}", scope: 'snsapi_base')
    end
  end

  private

  def logging
    logger.info "Current user: #{user_signed_in? ? current_user.id : 'guest'}"
    logger.info "Session: #{session.to_hash}"
    logger.info "> IP #{request.ip} Who #{user_signed_in? ? current_user.id : 'guest'} By #{request.method} What #{request.fullpath} When #{Time.now} From #{request.env['action_dispatch.request.unsigned_session_cookie']['previous_url']}"
  end

  def trim_param_id
    params[:id] and params[:id].gsub! /[^\w]$/, ''
  end

  def set_variant
    request.variant = if browser.tablet?
                        :tablet
                      elsif browser.mobile?
                        :mobile
                      else
                        :desktop
                      end
  end
end
