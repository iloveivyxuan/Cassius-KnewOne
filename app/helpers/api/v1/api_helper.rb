module Api
  module V1
    module ApiHelper
      def url_wrapper(*args)
        opts = args.extract_options!
        opts.merge! host: Settings.host

        polymorphic_url [opts.delete(:prepend), :api, :v1, *args].compact, opts
      end
    end
  end
end
