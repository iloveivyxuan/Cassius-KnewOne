# -*- coding: utf-8 -*-
module Hell
  class ApplicationController < ActionController::Metal
    SECRET = 'd15cd239'
    abstract!

    MODULES = [
        ActionController::Caching,
        ActionController::Helpers,
        ActionController::Redirecting,
        AbstractController::Rendering,
        ActionController::Rendering,
        ActionController::Renderers::All,
        ActionView::Layouts,
        ActionController::ConditionalGet,
        # need this for responding to different types .json .xml etc...
        ActionController::MimeResponds,
        ActionController::RequestForgeryProtection,
        # ActionController::ForceSSL,
        AbstractController::Callbacks,
        # need this to build params
        ActionController::Instrumentation,
        # need this for wrap_parameters
        ActionController::ParamsWrapper,
        ActionController::StrongParameters,
        ActionController::Rescue,
        ActionController::Head,
        Rails.application.routes.url_helpers,
    ]

    MODULES.each do |mod|
      include mod
    end

    # Define some internal variables that should not be propagated to the view.
    PROTECTED_IVARS = AbstractController::Rendering::DEFAULT_PROTECTED_INSTANCE_VARIABLES + [
        :@_status, :@_headers, :@_params, :@_env, :@_response, :@_request,
        :@_view_runtime, :@_stream, :@_url_options, :@_action_has_layout ]

    def _protected_ivars # :nodoc:
      PROTECTED_IVARS
    end

    def self.protected_instance_variables
      PROTECTED_IVARS
    end

    ActiveSupport.run_load_hooks(:action_controller, self)

    append_view_path "#{Rails.root}/app/views"

    prepend_before_action :check_expired
    prepend_before_action :check_sign
    after_action :respond_request

    rescue_from Mongoid::Errors::DocumentNotFound do
      head :not_found
    end

    rescue_from ApiRequestError do |ex|
      raise "Unknown error symbol #{ex.code}" unless INVALID_CODES.keys.include? ex.code

      @code, @message, @extra = INVALID_CODES[ex.code], ex.message, ex.extra
      render 'api/v1/shared/error', status: ex.status
    end

    INVALID_CODES = {
        :missing_field => 501,
        :nyi => 999
    }

    %w(api orders reviews things users).each do |h|
      helper "api/v1/#{h}"
    end

    protected

    def generate(params)
      timestamp = params.delete 'timestamp'

      query = params.sort.push(['timestamp', timestamp]).map do |key, value|
        "#{key}=#{value}"
      end.join('&')

      Digest::MD5.hexdigest("#{query}#{SECRET}")
    end

    def valid_sign?(params)
      params = params.stringify_keys
      sign = params.delete('sign')

      generate(params) == sign
    end

    def respond_request
      return unless self.response_body.nil?

      respond_to do |format|
        format.json
      end
    end

    def render_error(*attrbutes)
      extra = attrbutes.extract_options!
      err_sym = attrbutes[0]
      message = attrbutes[1]
      status = attrbutes[2].instance_of?(Symbol) ? attrbutes[2] : :unprocessable_entity
      raise ApiRequestError.new(err_sym, message, status, extra)
    end

    def check_expired
      if params[:timestamp].to_i < Time.now.to_i - 300
        raise ActionController::RoutingError.new('Not Found')
      end
    end

    def check_sign
      if params[:sign].blank? || !valid_sign?(params.except(*request.path_parameters.keys))
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end
end
