module Api
  module V1
    class ApiController < ActionController::Metal
      abstract!

      MODULES = [
          ActionController::Caching,
          ActionController::Helpers,
          ActionController::Redirecting,
          AbstractController::Rendering,
          ActionController::Rendering,
          ActionController::Renderers::All,
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
          Doorkeeper::Helpers::Filter,
          Devise::Controllers::Helpers,
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

      after_filter :respond_request

      rescue_from Mongoid::Errors::DocumentNotFound do
        head :not_found
      end

      rescue_from ApiRequestError do |ex|
        raise "Unknown error symbol #{ex.code}" unless INVALID_CODES.keys.include? ex.code

        @code, @message, @extra = INVALID_CODES[ex.code], ex.message, ex.extra
        render 'api/v1/shared/error', status: ex.status
      end

      %w(api orders reviews things users).each do |h|
        helper "api/v1/#{h}"
      end

      INVALID_CODES = {
          :missing_field => 501,
          :nyi => 999
      }

      protected
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

      def current_user
        if doorkeeper_token
          @current_user ||= User.find(doorkeeper_token.resource_owner_id)
        end
      end

      def user_signed_in?
        !current_user.nil?
      end
    end
  end
end
