class Entry
  include Mongoid::Document
  include Mongoid::Timestamps

  mount_uploader :cover, ImageUploader

  field :post_id, type: String
  field :thing_ids, type: Array, default: []
  field :category, type: String
  field :published, type: Boolean, default: false

  scope :published, -> {where published: true}

  validates :cover, :post_id, presence: true

  def post
    @_post ||= Post.find(self.post_id)
  end

  def things
    @_things ||= Thing.find(self.thing_ids)
  end

  CATEGORIES = %w(特写 评测 专题 活动)
end
