class UsersController < ApplicationController
  load_and_authorize_resource

  def show
    @things = @user.things
    @reviews = @user.reviews
  end
end
