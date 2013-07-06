class Net::HTTPResponse
  class Inflater
    ##
    # Finishes the inflate stream.

    def finish
      begin
        @inflate.finish
      rescue Zlib::DataError
        # No luck with Zlib decompression. Let's try with raw deflate,
        # like some broken web servers do.
        # taken by rest-client lib/restclient/request.rb L243-247
        @inflate = Zlib::Inflate.new(-Zlib::MAX_WBITS)
        retry
      end
    end

    ##
    # Returns a Net::ReadAdapter that inflates each read chunk into +dest+.
    #
    # This allows a large response body to be inflated without storing the
    # entire body in memory.

    def inflate_adapter(dest)
      block = proc do |compressed_chunk|
        begin
          @inflate.inflate(compressed_chunk) do |chunk|
            dest << chunk
          end
        rescue Zlib::DataError
          # No luck with Zlib decompression. Let's try with raw deflate,
          # like some broken web servers do.
          # taken by rest-client lib/restclient/request.rb L243-247
          @inflate = Zlib::Inflate.new(-Zlib::MAX_WBITS)
          retry
        end
      end

      Net::ReadAdapter.new(block)
    end
  end
end
