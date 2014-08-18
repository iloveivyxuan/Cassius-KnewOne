class InterestsController < ApplicationController
  prepend_before_action :require_signed_in
  skip_before_action :require_not_blocked

  def update
    category = Category.find(params[:id])

    if current_user.categories_text.include? category.name
      current_user.category_references >> category
    else
      current_user.category_references << category
    end

    head :no_content
  end
end
