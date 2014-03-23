# -*- coding: utf-8 -*-
class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :content, type: String, default: ""
  field :commented_at, type: DateTime

  validates :title, presence: true
  validates :content, presence: true

  belongs_to :author, class_name: "User", inverse_of: :post

  has_many :comments

  has_and_belongs_to_many :lovers, class_name: "User", inverse_of: nil
  has_and_belongs_to_many :foes, class_name: "User", inverse_of: nil
  field :lovers_count, type: Integer, default: 0

  has_many :related_lotteries, class_name: "Lottery",
           inverse_of: :contributions, dependent: :delete

  after_create :update_commented_at

  def update_commented_at
    update_attribute :commented_at, created_at
  end

  def vote(user, love)
    return if voted?(user)
    if love
      lovers << user
      author.inc karma: Settings.karma.post
    else
      foes << user
      author.inc karma: -Settings.karma.post
    end
    self.update_attribute :lovers_count, lovers.count
  end

  def voted?(user)
    lovers.include?(user) or foes.include?(user)
  end
end
