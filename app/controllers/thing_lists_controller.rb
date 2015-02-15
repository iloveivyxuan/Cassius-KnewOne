class ThingListsController < ApplicationController
  prepend_before_action :require_signed_in, only: :index
  load_and_authorize_resource except: :index

  respond_to :html, :json, :js

  def index
    @thing_lists = current_user.thing_lists
    respond_with @thing_lists
  end

  def show
    respond_with @thing_list
  end

  def create
    @thing_list.author = current_user
    @thing_list.save
    respond_with @thing_list
  end

  def update
    @thing_list.update(thing_list_params)
    respond_with @thing_list
  end

  def destroy
    @thing_list.destroy
    respond_with @thing_list
  end

  def fancy
    @thing_list.fancy(current_user)
    respond_with @thing_list

    current_user.log_activity(:fancy_list, @thing_list, check_recent: true)
  end

  def unfancy
    @thing_list.unfancy(current_user)
    respond_with @thing_list do |format|
      format.js { render 'fancy' }
    end
  end

  def sort
    order = params[:desc].to_s == 'true' ? :desc : :asc
    @thing_list.sort_items(created_at: order)
    @thing_list.save

    respond_with @thing_list
  end

  private

  def thing_list_params
    params.require(:thing_list).permit(:name, :description, :background_id)
  end
end
