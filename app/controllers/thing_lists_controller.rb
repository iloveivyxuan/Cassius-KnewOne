class ThingListsController < ApplicationController
  load_and_authorize_resource :user
  load_and_authorize_resource :thing_list, through: :user, shallow: true

  respond_to :html, :json, :js

  def show
    respond_with @thing_list
  end

  def create
    @thing_list.user = current_user
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
  end

  def unfancy
    @thing_list.unfancy(current_user)
    respond_with @thing_list do |format|
      format.js { render 'fancy' }
    end
  end

  private

  def thing_list_params
    params.require(:thing_list).permit(:name, :description)
  end
end
