class HomeController < ApplicationController
  layout 'application'
  skip_after_action :store_location, except: [:index]
  before_action :require_signed_in, only: [:welcome]

  def index
    return redirect_to landing_url unless user_signed_in?

    activities = current_user.related_activities.visible.by_types(:new_thing, :fancy_thing, :desire_thing, :own_thing,
                                                                  :new_review, :love_review,
                                                                  :new_feeling,
                                                                  :add_to_list, :fancy_list)

    return redirect_to welcome_url if activities.blank?

    @from_id = params[:from_id].to_s
    if @from_id.present?
      activities = activities.lte(id: params[:from_id])
    else
      @from_id = activities.first.try(:id).to_s || ''
    end

    activities = activities.page(params[:page]).per(30)
    @feeds = HomeFeed.create_from_activities activities

    if request.xhr?
      render 'index_xhr', layout: false
    end
  end

  def landing
    return redirect_to root_url if user_signed_in?

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
      @things = Thing.any_in(slugs: slugs)
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
      render 'hot_review', review: @review
    else
      head :unprocessable_entity
    end
  end
end
