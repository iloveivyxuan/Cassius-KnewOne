class SearchController < ApplicationController
  before_action :fix_query

  def index
    unless request.xhr?
      return redirect_to action: 'things', q: params[:q]
    end

    # @brands = Brand.search(params[:q]).limit(3)
    @things = Thing.search(params[:q]).limit(5)
    @lists = ThingList.search(params[:q]).limit(3)
    @users = User.search(params[:q]).limit(8)

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

    things = @things.records.only(:brand_id, :categories)

    brand_id, count = things.reduce(Hash.new(0)) do |counts, t|
      counts[t.brand_id] += 1 if t.brand_id
      counts
    end.sort_by(&:last).last

    @brand = Brand.where(id: brand_id).first if count && count > 10

    category_name, count = things.reduce(Hash.new(0)) do |counts, t|
      t.categories.each { |c| counts[c] += 1 }
      counts
    end.sort_by(&:last).last

    @category = Category.where(name: category_name).first if count && count > 10
  end

  def lists
    @lists = ThingList.search(params[:q]).page(params[:page]).per(24).records
  end

  def users
    @users = User.search(params[:q]).page(params[:page]).per(36).records
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
