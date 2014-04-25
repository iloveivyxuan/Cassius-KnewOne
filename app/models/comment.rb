# -*- coding: utf-8 -*-
class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Atable
  include Aftermath

  field :content, type: String

  belongs_to :post
  belongs_to :author, class_name: 'User'
  validates :author, presence: true

  validates :content, presence: true, length: {maximum: 300}

  default_scope -> { desc(:created_at) }

  after_create :update_commented_at
  after_destroy :update_commented_at

  def related_users
    content_users
    .push(post.author)
    .reject { |user| !user || user == author }
    .uniq
  end

  need_aftermath :create

  private

  def update_commented_at
    post.reload
    if post.comments.present?
      post.update_attribute :commented_at, post.comments.first.created_at
    else
      post.update_attribute :commented_at, post.created_at
    end
  end
end
