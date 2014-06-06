class Topic < Post
  include Aftermath

  field :is_top, type: Boolean, default: false

  belongs_to :group, counter_cache: true

  validates :title, presence: true
  validates :content, presence: true

  need_aftermath :vote
end
