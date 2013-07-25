class CustomerService::TicketsController < ::ApplicationController
  include ::ApplicationHelper
  load_and_authorize_resource

  # GET /customer_service/tickets
  # GET /customer_service/tickets.json
  def index
    @customer_service_tickets = CustomerService::Ticket.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @customer_service_tickets }
    end
  end

  # GET /customer_service/tickets/1/edit
  def edit
    @customer_service_ticket = CustomerService::Ticket.find(params[:id])
  end

  # POST /customer_service/tickets
  # POST /customer_service/tickets.json
  def create
    @customer_service_ticket = CustomerService::Ticket.new(params[:customer_service_ticket])
    @customer_service_ticket.user = current_user
    respond_to do |format|
      if @customer_service_ticket.save
        format.html { redirect_back_or(root_path) }
        format.json { render json: @customer_service_ticket, status: :created, location: @customer_service_ticket }
      else
        format.html { redirect_back_or(root_path) }
        format.json { render json: @customer_service_ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customer_service/tickets/1
  # DELETE /customer_service/tickets/1.json
  def destroy
    @customer_service_ticket = CustomerService::Ticket.find(params[:id])
    @customer_service_ticket.destroy

    respond_to do |format|
      format.html { redirect_to customer_service_tickets_url }
      format.json { head :no_content }
    end
  end
end
