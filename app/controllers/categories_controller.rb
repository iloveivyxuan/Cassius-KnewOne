class CategoriesController < ApplicationController
  load_and_authorize_resource

  def index
    @categories = Category.primary.prior.gt(things_count: 10)
  end

  def subscribe_toggle
    if current_user.categories.include? @category
      current_user.categories.delete @category
    else
      current_user.categories << @category
    end

    respond_to do |format|
      format.js
    end
  end
end
