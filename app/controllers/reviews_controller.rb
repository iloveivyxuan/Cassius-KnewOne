class ReviewsController < ApplicationController
  include MarkReadable
  include DestroyDraft

  load_and_authorize_resource :thing, singleton: true
  load_and_authorize_resource :review, through: :thing
  layout 'thing'
  after_action :allow_iframe_load, only: [:show]

  def index
    @reviews = if params[:sort] == "created_at"
                 @thing.reviews.desc(:created_at)
               else
                 @thing.reviews.desc(:is_top, :lovers_count, :created_at)
               end.page(params[:page]).per(params[:per])

    if request.xhr?
      render 'reviews/index_xhr', layout: false
    else
      render 'reviews/index'
    end
  end

  def show
    mark_read @review
  end

  def new
    respond_to do |format|
      format.html.mobile { render 'new' }
      format.html.tablet { render 'new.html+mobile' }
      format.html.desktop { render layout: 'application' }
    end
  end

  def create
    # review whose content is less than 140 will be transformed to feeling.
    review_content = ActionView::Base.full_sanitizer.sanitize(@review.content)
    if !images_inside? && !iframe_inside? && (review_content.size < 140)
      @feeling = Feeling.new
      %w(title score thing).each { |attr| @feeling[attr] = @review[attr] }
      @feeling.content = review_content
      @feeling.author = current_user
      # add photos for feeling
      Nokogiri::HTML(@review.content).xpath("//img").each do |i|
        p = Photo.new
        p.remote_image_url = i.attributes["src"].value.split("!").first
        p.user = current_user
        p.save
        @feeling.photo_ids << p.id if p.persisted?
      end
      if @feeling.save
        flash[:provider_sync] = params[:provider_sync]
        current_user.log_activity :new_feeling, @feeling, source: @feeling.thing
        redirect_to thing_feeling_url(@thing, @feeling)
      else
        flash.now[:error] = @feeling.errors.full_messages.first
        render 'new'
      end
    else
      @review.author = current_user
      @review.thing = Thing.find(params[:thing_id])
      if @review.save
        content_users = mentioned_users(@review.content)
        content_users.each do |u|
          u.notify :review, context: @review, sender: current_user, opened: false
        end

        flash[:provider_sync] = params[:provider_sync]
        current_user.log_activity :new_review, @review, source: @review.thing
        redirect_to thing_review_url(@thing, @review)
      else
        flash.now[:error] = @review.errors.full_messages.first
        render 'new'
      end
    end
  end

  def edit
    respond_to do |format|
      format.html.mobile { render 'new' }
      format.html.tablet { render 'new.html+mobile' }
      format.html.desktop { render 'new', layout: 'application' }
    end
  end

  def update
    if @review.update(review_params)
      redirect_to thing_review_path(@thing, @review)
    else
      flash.now[:error] = @review.errors.full_messages.first
      render 'new'
    end
  end

  def destroy
    @review.destroy
    current_user.log_activity :delete_review, @review, visible: false
    redirect_to thing_reviews_path(@thing)
  end

  def vote
    @review.vote(current_user, true)

    current_user.log_activity :love_review, @review, source: @review.thing

    respond_to do |format|
      format.js { render partial: 'shared/vote', locals: {object: @review} }
    end
  end

  def unvote
    @review.unvote(current_user, true)

    respond_to do |format|
      format.js { render partial: 'shared/vote', locals: {object: @review} }
    end
  end

  private

  def review_params
    permit_attrs = [:title, :content, :score]
    permit_attrs.concat [:is_top, :author] if current_user && current_user.role?(:editor)
    params.require(:review).permit permit_attrs
  end

  def images_inside?
    !Nokogiri::HTML(@review.content).xpath("//img").empty?
  end

  def iframe_inside?
    !Nokogiri::HTML(@review.content).xpath("//iframe").empty?
  end
end
