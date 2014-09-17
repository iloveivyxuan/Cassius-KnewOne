class TagsController < ApplicationController
  layout 'settings'

  def fuzzy
    @tags = Tag.find_by_sequence(params[:query])
    respond_to do |format|
      format.json do
        @tags = @tags.limit(20)
      end
    end
  end

end
