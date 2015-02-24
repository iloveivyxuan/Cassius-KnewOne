class PrizesController < ApplicationController
  def index
    @prizes = Prize.all.valid
    params[:page] ||= 1
    valid_prizes = Prize.valid.distinct(:since).sort.reverse
    since_date = valid_prizes[5 * params[:page].to_i - 1]
    due_date = valid_prizes[5 * (params[:page].to_i - 1)]
    @prizes = @prizes.gte(since: since_date).lte(since: due_date)
  end
end
