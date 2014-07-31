module Api
  module V1
    class EntriesController < ApiController
      def show
        @entry = Entry.find(params[:id])
      end
    end
  end
end
