class MapsController < ApplicationController
  def things
    @things = Thing.published.desc(:created_at).page(params[:page]).per(200)
  end

  def reviews
    @reviews = Review.living.desc(:created_at).page(params[:page]).per(200)
  end

  def topics
    @topics = Topic.all.desc(:created_at).page(params[:page]).per(200)
  end

  def groups
    @groups = Group.public.desc(:created_at).page(params[:page]).per(200)
  end

  def categories
    @categories = Category.where(:things_count.gt => 0)
  end
end
