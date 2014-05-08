module Api
  module V1
    class ApiController < ActionController::Metal
      abstract!

      MODULES = [
          AbstractController::Rendering,

          ActionController::Helpers,
          ActionController::HideActions,
          ActionController::UrlFor,
          ActionController::Redirecting,
          ActionView::Layouts,
          ActionController::Head,
          ActionController::Rendering,
          ActionController::Renderers::All,
          ActionController::ConditionalGet,
          ActionController::RackDelegation,
          ActionController::Caching,
          ActionController::MimeResponds,
          ActionController::ImplicitRender,
          ActionController::StrongParameters,

          ActionController::ForceSSL,

          # Before callbacks should also be executed the earliest as possible, so
          # also include them at the bottom.
          AbstractController::Callbacks,

          # Append rescue at the bottom to wrap as much as possible.
          ActionController::Rescue,

          # Add instrumentations hooks at the bottom, to ensure they instrument
          # all the methods properly.
          ActionController::Instrumentation,

          # Params wrapper should come before instrumentation so they are
          # properly showed in logs
          ActionController::ParamsWrapper,

          Doorkeeper::Helpers::Filter,
          Devise::Controllers::Helpers,
          Rails.application.routes.url_helpers
      ]

      MODULES.each do |mod|
        include mod
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
