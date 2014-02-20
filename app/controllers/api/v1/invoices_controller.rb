module Api
  module V1
    class AddressesController < ApiController
      doorkeeper_for :all

      def show
        @invoice = current_user.invoices.find params[:id]
      end

      def index
        @invoices = current_user.invoices
      end

      def create
        invoice = current_user.invoices.build invoice_params
        if invoice.save
          render action: 'show', status: :created, location: @invoice
        else
          render json: invoice.errors, status: :unprocessable_entity
        end
      end

      def update
        invoice = current_user.invoices.find params[:id]
        if invoice.update(invoice_params)
          head :no_content
        else
          render json: invoice.errors, status: :unprocessable_entity
        end
      end

      def destroy
        invoice = current_user.invoices.find params[:id]
        invoice.destroy
        head :no_content
      end

      private

      def invoice_params
        params.require(:invoice).permit(:kind, :title, :content)
      end
    end
  end
end
