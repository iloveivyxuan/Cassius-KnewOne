module Api
  module V1
    module ApiHelper
      def url_wrapper(*args)
        opts = args.extract_options!
        opts.merge! host: Settings.host
        polymorphic_url [:api, :v1, *args], opts
      end
    end
  end
end
