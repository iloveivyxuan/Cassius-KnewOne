# -*- coding: utf-8 -*-
class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  include Mongoid::Taggable

  field :title, type: String
  field :content, type: String, default: ""
  field :commented_at, type: DateTime

  belongs_to :author, class_name: "User", inverse_of: :post

  embeds_many :comments

  validates :title, presence: true
  validates :content, presence: true

  has_many :related_lotteries, class_name: "Lottery",
  inverse_of: :contributions, dependent: :delete

  after_create :update_commented_at

  def update_commented_at
    update_attribute :commented_at, created_at
  end
end
