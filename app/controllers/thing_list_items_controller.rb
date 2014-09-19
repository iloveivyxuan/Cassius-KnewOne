class ThingListItemsController < ApplicationController
  load_and_authorize_resource :thing_list
  load_and_authorize_resource :thing_list_item, through: :thing_list

  respond_to :json, :js

  def create
    @thing_list_item.save
    respond_with @thing_list, @thing_list_item

    current_user.log_activity(:add_to_list, @thing_list_item.thing, source: @thing_list)
  end

  def update
    @thing_list_item.update(thing_list_item_params)
    respond_with @thing_list_item
  end

  def destroy
    @thing_list_item.destroy
    respond_with @thing_list_item
  end

  private

  def thing_list_item_params
    params.require(:thing_list_item).permit(:thing_id, :description, :order)
  end
end
