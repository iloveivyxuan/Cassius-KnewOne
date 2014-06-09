#encoding: utf-8
class Entry
  include Mongoid::Document
  include Mongoid::Timestamps

  mount_uploader :cover, ImageUploader

  belongs_to :post

  field :external_link, type: String
  field :title, type: String
  field :sharing_content, type: String
  field :thing_ids, type: Array, default: []
  field :category, type: String
  field :published, type: Boolean, default: false

  scope :published, -> {where published: true}

  validate do
    if self.post.blank? && self.title.blank?
      errors.add :title, '必须提供一个标题'
    end
    if self.post.blank? && self.external_link.blank?
      errors.add :post_id, '外部链接和文章必选其一'
    end
  end

  def post
    @_post ||= Post.where(id: self.post_id).first
  end

  def things
    @_things ||= Thing.or({:id.in => self.thing_ids}, {:slugs.in => self.thing_ids})
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

  CATEGORIES = {
      '特写' => 'features',
      '评测' => 'reviews',
      '专题' => 'specials',
      '活动' => 'events'
  }
end
