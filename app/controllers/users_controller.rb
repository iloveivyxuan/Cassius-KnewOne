class UsersController < ApplicationController
  load_and_authorize_resource

  after_filter :store_location, only: [:show]

  def show
    @things = @user.things
    @reviews = @user.reviews
  end
end
