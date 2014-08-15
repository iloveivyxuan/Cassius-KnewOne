class Topic < Post
  include Aftermath

  field :is_top, type: Boolean, default: false

  belongs_to :group, counter_cache: true

  validates :title, presence: true
  validates :content, presence: true

  field :visible, type: Boolean, default: true
  scope :visible, -> { where visible: true }  

  need_aftermath :vote
end
