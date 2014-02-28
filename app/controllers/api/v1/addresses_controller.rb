module Api
  module V1
    class AddressesController < ApiController
      doorkeeper_for :all, scopes: [:official]

      def show
        @address = current_user.addresses.find params[:id]
      end

      def index
        @addresses = current_user.addresses
      end

      def create
        address = current_user.addresses.build address_params
        if address.save
          render action: 'show', status: :created, location: @address
        else
          render json: address.errors, status: :unprocessable_entity
        end
      end

      def update
        address = current_user.addresses.find params[:id]
        if address.update(address_params)
          head :no_content
        else
          render json: address.errors, status: :unprocessable_entity
        end
      end

      def destroy
        address = current_user.addresses.find params[:id]
        address.destroy
        head :no_content
      end

      private

      def address_params
        params.require(:address)
        .permit(:province, :district, :street, :name, :phone, :zip_code)
      end
    end
  end
end
