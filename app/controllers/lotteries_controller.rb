# -*- coding: utf-8 -*-
class LotteriesController < ApplicationController
  load_and_authorize_resource

  def index
    @lotteries = Lottery.page params[:page]
  end

  def new
    if params[:thing]
      post = Thing.find params[:thing]
      @lottery.contribution_link = thing_url(post)
    elsif params[:review]
      post = Review.find params[:review]
      @lottery.contribution_link = thing_review_url(post.thing, post)
    end
    @lottery.winner_link = user_url(post.author)
    @lottery.date = post.created_at
  end

  def create
     @lottery = Lottery.new params[:lottery]
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
    if @lottery.update_attributes(params[:lottery])
      redirect_to lotteries_path
    else
      render 'new'
    end
  end

  def destroy
    @lottery.destroy
    redirect_to lotteries_path
  end
end
