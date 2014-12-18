class SearchController < ApplicationController
  def index
    q = params[:q].to_s

    return head :no_content if q.empty?
    per = params[:per_page] || 48

    if (params[:type].blank? && params[:format].blank?) || !['things', 'users', nil].include?(params[:type])
      params[:type] = 'things'
    end

    if params[:type].blank? || params[:type] == 'things'
      @things = Thing.search(q).page(params[:page]).per(per).records
    end

    if params[:type].blank? || params[:type] == 'users'
      @users = User.search(q).page(params[:page]).per(per).records
    end

    @category = Category.search(q).limit(1).records.first
    @tag = Tag.search(q).limit(1).records.first
    @brand = Brand.search(q).limit(1).records.first

    respond_to do |format|
      format.html do
        if request.xhr?
          render 'index_xhr', layout: false
        else
          render "search_#{params[:type]}", layout: 'search'
        end
      end

      format.json
    end
  end

  def suggestions
    q = params[:q].to_s
    @suggestions = Thing.suggest(q, 3)

    respond_to do |format|
      format.json { render json: @suggestions }
    end
  end
end
