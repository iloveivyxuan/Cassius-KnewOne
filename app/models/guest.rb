# -*- coding: utf-8 -*-
class Guest
  include Mongoid::Document
  include Mongoid::Timestamps

  field :token, type: String

  belongs_to :user

  validates :token, presence: true

  default_scope desc(:created_at)

  class << self
    def create
      super token: SecureRandom.urlsafe_base64
    end
  end

end
