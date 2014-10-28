class BongPointTransaction
  include Mongoid::Document
  include Mongoid::Timestamps

  TYPES = {
    consuming: '消费',
    refunding: '退还'
  }
  belongs_to :order

  field :bong_point, type: Integer, default: 0
  field :success, type: Boolean, default: true
  field :code, type: String
  field :type, type: Symbol

  field :raw, type: Hash

  validates :type, inclusion: {in: TYPES.keys}

  scope :success, -> { where success: true }

  TYPES.keys.each do |s|
    scope s, -> { where type: s }
  end
end
