class BongPointTransaction
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :order

  field :bong_point, type: Integer, default: 0
  field :success, type: Boolean, default: true
  field :code, type: String

  field :raw, type: Hash

  scope :success, -> { where success: true }
end
