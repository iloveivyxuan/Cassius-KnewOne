class PrizesController < ApplicationController
  def index
    @prizes = Prize.all.valid
    params[:page] ||= 1
    since_date = params[:page].day.ago.to_date
    due_date = (params[:page] * 5).day.ago.to_date
    @prizes = @prizes.gte(due: due_date).lte(since: since_date)
  end
end
