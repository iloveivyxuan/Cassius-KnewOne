class ReviewsController < PostsController
  load_and_authorize_resource :thing, except: [:admin]
  after_filter :store_location, only: [:index, :show]
  layout 'thing', except: [:admin]

  def admin
    @reviews = Review.page params[:page]
    render 'index'
  end

  def index
    @reviews = @thing.reviews.page params[:page]
  end

  def show
    if user_signed_in?
      CommentMessage.read_by_post(current_user, @review)
    end
  end

  def new
    @review = Review.new
  end

  def create
    @review = Review.new params[:review]
      .merge(author: current_user, thing: @thing)
    if @review.save
      redirect_to thing_review_path(@thing, @review)
    else
      render 'new'
    end
  end

  def edit
    render 'new'
  end

  def update
    if @review.update_attributes(params[:review])
      redirect_to thing_review_path(@thing, @review)
    else
      flash.now[:error] = @review.errors.full_messages.first
      render 'new'
    end
  end

  def destroy
    @review.destroy
    redirect_to @thing
  end

  def vote
    @review.vote current_user, params[:vote] == "true"
    render "_voting", locals: {review: @review}, layout: false
  end
end
