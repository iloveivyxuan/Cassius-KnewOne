class InvoicesController < ApplicationController
  before_action :require_signed_in
  layout 'settings'

  def index
    @invoices = current_user.invoices
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @invoices }
    end
  end

  def new
    @invoice = current_user.invoices.build
    respond_to do |format|
      format.html { render 'new' }
      format.json { render json: @invoice }
    end
  end

  def create
    @invoice = current_user.invoices.build invoice_params
    respond_to do |format|
      if @invoice.save
        format.html { redirect_back_or(invoices_path) }
        format.json { render json: @invoice, status: :created, location: @invoice }
      else
        format.html { render action: "new" }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @invoice = current_user.invoices.find params[:id]
  end

  def update
    @invoice = current_user.invoices.find params[:id]
    respond_to do |format|
      if @invoice.update(invoice_params)
        format.html { redirect_back_or(invoices_path) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @invoice = current_user.invoices.find params[:id]
    @invoice.destroy
    respond_to do |format|
      format.html { redirect_to invoices_path }
      format.json { head :no_content }
    end
  end

  private

  def invoice_params
    params.require(:invoice)
      .permit(:kind, :title, :content)
  end
end
