# -*- coding: utf-8 -*-
module Haven
  class ReviewsController < ApplicationController
    layout 'settings'

    def index
      @reviews = Review.desc(:created_at).page params[:page]
    end
  end
end
