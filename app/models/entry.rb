#encoding: utf-8
class Entry
  include Mongoid::Document
  include Mongoid::Timestamps

  mount_uploader :cover, ImageUploader

  field :post_id, type: String
  field :thing_ids, type: Array, default: []
  field :category, type: String
  field :published, type: Boolean, default: false

  scope :published, -> {where published: true}

  validates :post_id, presence: true

  def post
    @_post ||= Post.find(self.post_id)
  end

  def things
    @_things ||= Thing.find(self.thing_ids)
  end

  def previous(same_category = true)
    if same_category
      self.class.where(:_id.lt => self._id, category: self.category).order_by([[:_id, :desc]]).limit(1).first
    else
      self.class.where(:_id.lt => self._id).order_by([[:_id, :desc]]).limit(1).first
    end
  end

  def next(same_category = true)
    if same_category
      self.class.where(:_id.gt => self._id, category: self.category).order_by([[:_id, :asc]]).limit(1).first
    else
      self.class.where(:_id.gt => self._id).order_by([[:_id, :asc]]).limit(1).first
    end
  end

  CATEGORIES = %w(特写 评测 专题 活动)
end
