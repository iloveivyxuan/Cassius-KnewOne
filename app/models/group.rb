# -*- coding: utf-8 -*-
class Group
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :description, type: String

  belongs_to :founder, class_name: "User", inverse_of: :found_group

  has_many :topics

  default_scope -> { desc(:created_at) }

  scope :classic, -> { where(:'_type'.exists => false) }

  validates :name, presence: true
  validates :founder, presence: true
end
