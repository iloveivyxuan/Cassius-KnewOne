class Entry
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::MultiParameterAttributes

  include Rails.application.routes.url_helpers

  mount_uploader :cover, ImageUploader
  mount_uploader :canopy, ImageUploader
  mount_uploader :wechat_cover, ImageUploader
  mount_uploader :avatar, ImageUploader

  belongs_to :post

  field :external_link, type: String
  field :title, type: String
  field :wechat_title, type: String
  field :sharing_content, type: String
  field :thing_ids, type: Array, default: []
  field :category, type: String
  field :published, type: Boolean, default: false
  field :summary, type: String
  field :cover_img, type: Symbol, default: :canopy

  scope :published, -> {where published: true}

  after_save :review_entry

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
      self.class.where(:_id.lt => self._id, category: self.category, published: true).order_by([[:_id, :desc]]).limit(1).first
    else
      self.class.where(:_id.lt => self._id, published: true).order_by([[:_id, :desc]]).limit(1).first
    end
  end

  def next(same_category = true)
    if same_category
      self.class.where(:_id.gt => self._id, category: self.category, published: true).order_by([[:_id, :asc]]).limit(1).first
    else
      self.class.where(:_id.gt => self._id, published: true).order_by([[:_id, :asc]]).limit(1).first
    end
  end

  CATEGORIES = {
    '专访' => 'talks',
    '列表' => 'lists',
    '评测' => 'reviews',
    '特写' => 'features',
    '专题' => 'specials',
    '活动' => 'events'
  }

  def review_entry
    if self.post.is_a?(Review) && !self.published_was && self.published
      user = self.post.author
      knewone = User.where(id: '511114fa7373c2e3180000b4').first
      url = entry_url(self, host: "knewone.com")

      return unless user && knewone && url
      content = "Hi, 感谢你在 KnewOne 分享的测评《#{self.post.title}》，写得太赞啦！我们已将其收录至 <a href='#{url}'>精选频道</a>，感谢你，欢迎继续将更多体验与大家分享喔！┏ (゜ω゜)=☞"
      knewone.send_private_message_to(user, content)
    end
  end

  def category_translation
    case self.category
    when '专访'
      'talk'
    when '列表'
      'list'
    when '评测'
      'review'
    when '特写'
      'feature'
    when '专题'
      'special'
    when '活动'
      'event'
    else
      return
    end
  end

end
