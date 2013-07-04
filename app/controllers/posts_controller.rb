# -*- coding: utf-8 -*-
class PostsController < ApplicationController
  load_and_authorize_resource
  after_filter :store_location, only: [:index, :show]

  def read_comments(post)
    if user_signed_in?
      CommentMessage.read_by_post(current_user, post)
    end
  end
end
