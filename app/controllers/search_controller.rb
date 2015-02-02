class SearchController < ApplicationController
  before_action :fix_query
  before_action :fix_page
  before_action :redirect_empty_query

  def index
    unless request.xhr?
      return redirect_to action: 'things', q: params[:q]
    end

    # @brands = Brand.search(params[:q]).limit(3)
    @things = Thing.search(params[:q]).limit(4)
    @lists = ThingList.search(params[:q]).limit(3)
    @users = User.search(params[:q]).limit(6)
    @topics = Topic.search(params[:q]).limit(1)

    render 'index_xhr', layout: false
  end

  def suggestions
    @suggestions = Thing.suggest(params[:q], 3)

    respond_to do |format|
      format.json { render json: @suggestions }
    end
  end

  def things
    @things = Thing.search(params[:q]).page(params[:page]).per(24)

    return if params[:page].to_i > 1

    things = @things.records.only(:brand_id, :categories)

    brand_id, count = things.reduce(Hash.new(0)) do |counts, t|
      counts[t.brand_id] += 1 if t.brand_id
      counts
    end.sort_by(&:last).last

    @brand = Brand.where(id: brand_id).first if count && count > things.size * 0.3
    @brand ||= Brand.search(params[:q]).limit(1).records.first

    category_name, count = things.reduce(Hash.new(0)) do |counts, t|
      t.categories.each { |c| counts[c] += 1 }
      counts
    end.sort_by(&:last).last

    if count && count > things.size * 0.5
      @category = Category.only(:name, :icon, :slugs).where(name: category_name).first
    end
  end

  def lists
    @lists = ThingList.search(params[:q]).page(params[:page]).per(24)
  end

  def users
    @users = User.search(params[:q]).page(params[:page]).per(36)
  end

  def topics
    @topics = Topic.search(params[:q]).page(params[:page]).per(24)

    unless params[:page].to_i > 1
      @groups = Group.search(params[:q]).limit(4)
    end
  end

  private

  def fix_query
    params[:q] = params[:q].to_s
  end

  def fix_page
    params[:page] = params[:page].first if params[:page].is_a?(Array)
  end

  def redirect_empty_query
    redirect_to root_url if params[:q].blank? && !request.xhr?
  end
end
