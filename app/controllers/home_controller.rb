class HomeController < ApplicationController
  layout 'application'
  skip_after_action :store_location, except: [:index]
  before_action :authenticate_user!, only: [:welcome]

  def index
    if user_signed_in?
      @source = (params[:source] or session[:source] or "following")

      if @source == "following" and current_user.followings_count > 0
        session[:source] = @source
        activities = current_user.related_activities.visible.by_types(:new_thing, :own_thing, :fancy_thing,
                                                                      :new_review, :love_review,
                                                                      :new_feeling,
                                                                      :add_to_list, :fancy_list)
        activities = activities.page(params[:page]).per(30)
        @feeds = HomeFeed.create_from_activities activities
        @pager = activities
      else
        session[:source] = "latest"
        things = Thing.published.recommended.desc(:approved_at)
        things = things.page(params[:page]).per(30)
        reviews = []
        @feeds = HomeFeed.create_from_things_and_reviews(things, reviews)
        @pager = things
      end
    else
      respond_to do |format|
        format.html.mobile do
          hits
          render 'home/landing.html+mobile' unless request.xhr?
        end

        format.html.tablet do
          hits
          render 'home/landing.html+mobile' unless request.xhr?
        end

        format.html.desktop do
          @categories = Category.top_level.gt(things_count: 10).desc(:things_count)
          render 'home/landing'
        end
      end
    end
  end

  def hits
    @batch = 5
    @things = Thing.hot.recommended.page(params[:page]).per(6*@batch)
    @reviews = Review.hot.page(params[:page]).per(@batch)
    @thing_lists = ThingList.hot.page(params[:page]).per(@batch)

    if request.xhr?
      render 'hits_xhr', layout: false
    end
  end

  def not_found
    respond_to do |format|
      format.js { head :not_found }
      format.json { head :not_found }
      format.html { render status: :not_found }
    end
  end

  def forbidden
    if user_signed_in?
      render 'home/forbidden_signed_in', status: :forbidden
    else
      render 'home/forbidden', status: :forbidden
    end
  end

  def blocked

  end

  def welcome
    @friends = current_user.recommend_users || []
    @categories = Category.desc(:things_count).limit(9)
  end

  def error
    respond_to do |format|
      format.js { head :internal_server_error }
      format.json { head :internal_server_error }
      format.html { render status: :internal_server_error }
    end
  end

  def qr_entry
    redirect_to "sinaweibo://userinfo?uid=3160959662"
  end

  def jobs
  end

  def user_agreement
  end

  def sale_terms
  end

  def wxpay_alert
    logger.info params.except(*request.path_parameters.keys)
    head :no_content
  end

  def embed
    return head :unprocessable_entity if params[:key].blank?

    case params[:type]
    when 'thing'
      slugs = params[:key].split(',')
      @things = Thing.in(slugs: slugs).sort_by { |thing| slugs.index(thing.slug) }
      if params[:options]
        photos = params[:options][:photos].split(',')
      else
        photos = Array.new(@things.size, "")
      end
      render partial: 'things/embed_thing', collection: @things.zip(photos), locals: { klass: (slugs.size > 1) ? 'col-sm-6' : 'col-sm-12' }, as: 'embed'
    when 'list'
      @list = ThingList.find params[:key]
      render [@list], locals: { layout: browser.desktop? ? :quintet : :grid }
    when 'review'
      @review = Review.find params[:key]
      render partial: 'hot_review', collection: [@review]
    else
      head :unprocessable_entity
    end
  end
end
