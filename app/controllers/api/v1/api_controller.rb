module Api
  module V1
    class ApiController < ActionController::Metal
      abstract!

      MODULES = [
          ActionController::Helpers,
          ActionController::Redirecting,
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
          Devise::Controllers::Helpers,
          Rails.application.routes.url_helpers,
      ]

      MODULES.each do |mod|
        include mod
      end

      # Define some internal variables that should not be propagated to the view.
      self.protected_instance_variables = [
          :@_status, :@_headers, :@_params, :@_env, :@_response, :@_request,
          :@_view_runtime, :@_stream, :@_url_options, :@_action_has_layout
      ]

      ActiveSupport.run_load_hooks(:action_controller, self)

      append_view_path "#{Rails.root}/app/views"

      after_filter :respond_request

      protect_from_forgery

      rescue_from Mongoid::Errors::DocumentNotFound do
        head :not_found
      end

      rescue_from ApiRequestError do |ex|
        raise "Unknown error symbol #{ex.code}" unless INVALID_CODES.keys.include? ex.code

        @code, @message = INVALID_CODES[ex.code], ex.message
        render 'api/v1/shared/error', status: ex.status
      end

      helper 'api/v1/api'

      INVALID_CODES = {
          :missing_parameter => 501,
          :nyi => 999
      }

      protected

      def respond_request
        respond_to do |format|
          format.json
        end
      end

      def render_error(err_sym, message, status = :bad_request)
        raise ApiRequestError.new(err_sym, message, status)
      end
    end
  end
end
