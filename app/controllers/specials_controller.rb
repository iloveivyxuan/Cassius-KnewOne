class SpecialsController < ApplicationController
  layout false

  prepend_before_action :require_signed_in, except: [:valentine, :womensday]
  before_action :set_article, except: [:valentine, :womensday]

  def vote
    @special.vote(current_user, true)

    respond_to do |format|
      format.js { render partial: 'shared/vote', locals: {object: @special} }
    end
  end

  def unvote
    @special.unvote(current_user, true)

    respond_to do |format|
      format.js { render partial: 'shared/vote', locals: {object: @special} }
    end
  end

  def valentine
  end

  def womensday
  end

  private

  def set_article
    @special = Special.find(params[:id])
  end
end
