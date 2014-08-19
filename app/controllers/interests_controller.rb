class InterestsController < ApplicationController
  prepend_before_action :require_signed_in
  skip_before_action :require_not_blocked

  def update
    category = Category.find(params[:id])

    if current_user.categories.include? category
      current_user.categories.delete category
    else
      current_user.categories << category
    end

    head :no_content
  end
end
