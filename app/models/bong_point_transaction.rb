class BongPointTransaction
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :order

  field :request_bong_point, type: Integer
  field :consumed_bong_point, type: Integer, default: 0
  field :success, type: Boolean

  field :raw, type: Hash
end
