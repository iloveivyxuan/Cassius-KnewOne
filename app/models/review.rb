class Review < Post
  include Rateable
  include Aftermath

  field :is_top, type: Boolean, default: false

  belongs_to :thing, counter_cache: true

  validates :title, presence: true
  validates :content, presence: true

  default_scope -> { desc(:is_top, :lovers_count, :created_at) }

  scope :living, -> { where :thing_id.ne => nil }

  need_aftermath :create, :destroy, :vote

  def official_cover(version = :small)
    src = self.content.scan(/<img src=\"(.+?)\"/).try(:[], 0).try(:[], 0)
    return nil unless src.present? and src[0..23] == 'http://image.knewone.com'

    src.gsub(/!.*$/, "!#{version}")
  end
end
