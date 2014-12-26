class PrizesController < ApplicationController
  def index
    @prizes = Prize.all.valid
    params[:page] ||= 1
    since_date = (5 * (params[:page].to_i - 1) + 1).day.ago.to_date
    due_date = (params[:page].to_i * 5).day.ago.to_date
    @prizes = @prizes.gte(due: due_date).lte(since: since_date)
  end
end
