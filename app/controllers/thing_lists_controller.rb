class ThingListsController < ApplicationController
  load_and_authorize_resource :user
  load_and_authorize_resource :thing_list, through: :user, shallow: true

  respond_to :html, :json

  def index
    unless @user
      return respond_to do |format|
        format.html { redirect_to '/403' }
        format.json { head :forbidden }
      end unless user_signed_in?

      @user = current_user
      @thing_lists = current_user.thing_lists
    end

    respond_with @thing_lists
  end

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
    head :no_content
  end

  def unfancy
    @thing_list.unfancy(current_user)
    head :no_content
  end

  private

  def thing_list_params
    params.require(:thing_list).permit(:name, :description)
  end
end
