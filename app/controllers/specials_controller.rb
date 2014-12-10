class SpecialsController < ApplicationController
  layout false

  prepend_before_action :require_signed_in
  before_action :set_special

  def vote
    @special.vote(current_user)

    respond_to do |format|
      format.js { render partial: 'shared/vote', locals: {object: @special} }
    end
  end

  def unvote
    @special.unvote(current_user)

    respond_to do |format|
      format.js { render partial: 'shared/vote', locals: {object: @special} }
    end
  end

  private

  def set_special
    @special = Special.find(params[:id])
  end
end
