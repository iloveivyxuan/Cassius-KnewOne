class LotteriesController < ApplicationController
  load_and_authorize_resource

  def index
    respond_to do |format|
      format.html { @lotteries = @lotteries.page params[:page] }
      format.csv do
        lines = [%w(日期 奖品 获奖原因 获奖用户) + (can?(:manage, :all) ? %w(姓名 电话 地址 发货) : %w())]

        @lotteries.each do |lottery|
          cols = [
              lottery.date,
              lottery.thing.title,
              (lottery.contribution ? lottery.contribution.title : '?'), lottery.winner.name
          ]
          if can?(:manage, :all)
            cols += [
                lottery.name, '| ' + lottery.phone.to_s,
                lottery.address,
                (lottery.is_delivered ? '| ' + lottery.delivery : '未投递')
            ]
          end
          lines<< cols
        end

        csv = CSV.generate :col_sep => ';' do |csv|
          lines.each {|l| csv<< l }
        end

        if params[:encoding] == 'gb2312'
          send_data csv.encode 'gb2312', :replace => ''
        else
          send_data csv, :replace => ''
        end
      end
    end
  end

  def new
    if params[:thing]
      post = Thing.find params[:thing]
      @lottery.contribution_link = thing_url(post)
    elsif params[:review]
      post = Review.find params[:review]
      @lottery.contribution_link = thing_review_url(post.thing, post)
    else
      return
    end
    @lottery.winner_link = user_url(post.author)
    @lottery.date = post.created_at
  end

  def create
    @lottery = Lottery.new lottery_params
    if @lottery.save
      redirect_to lotteries_path
    else
      render 'new'
    end
  end

  def edit
    render 'new'
  end

  def update
    if @lottery.update(lottery_params)
      redirect_to lotteries_path
    else
      render 'new'
    end
  end

  def destroy
    @lottery.destroy
    redirect_to lotteries_path
  end

  private

  def lottery_params
    params.require(:lottery).permit!
  end
end
