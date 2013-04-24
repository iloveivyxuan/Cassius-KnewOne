class PostsController < ApplicationController
  load_and_authorize_resource
  after_filter :store_location, only: [:index, :show]
end
