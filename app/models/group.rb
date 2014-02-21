# -*- coding: utf-8 -*-
class Group
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :description, type: String

  has_many :topics
  embeds_many :members do
    def add(user, role)
      @base.members.delete_all user_id: user.id
      @base.members << Member.new(user_id: user.id, role: role)
    end
  end

  default_scope -> { desc(:created_at) }

  validates :name, presence: true

  def has_admin?(user)
    members.where(user_id: user.id).exists?
  end
end
