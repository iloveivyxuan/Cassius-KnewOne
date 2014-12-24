class SearchController < ApplicationController
  before_action :fix_query

  def index
    unless request.xhr?
      return redirect_to action: 'things', q: params[:q]
    end

    @brands = Brand.search(params[:q]).limit(3)
    @things = Thing.search(params[:q]).limit(5).records.to_a
    @lists = ThingList.search(params[:q]).limit(3).records.qualified.to_a
    @users = User.search(params[:q]).limit(8).records.to_a

    render 'index_xhr', layout: false
  end

  def suggestions
    @suggestions = Thing.suggest(params[:q], 3)

    respond_to do |format|
      format.json { render json: @suggestions }
    end
  end

  def things
    @things = Thing.search(params[:q]).page(params[:page]).per(24).records
  end

  def lists
    @lists = ThingList.search(params[:q]).page(params[:page]).per(24).records
  end

  def users
    @users = User.search(params[:q]).page(params[:page]).per(24).records
  end

  def groups
    @groups = Group.search(params[:q]).page(params[:page]).per(24).records
    @topics = Topic.search(params[:q]).page(params[:page]).per(24).records
  end

  private

  def fix_query
    params[:q] = params[:q].to_s
  end
end
