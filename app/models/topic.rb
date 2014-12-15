class Topic < Post
  include Aftermath

  field :is_top, type: Boolean, default: false

  belongs_to :group, counter_cache: true, index: true

  validates :title, presence: true
  validates :content, presence: true

  field :visible, type: Boolean, default: true
  scope :visible, -> { where visible: true }

  field :approved, type: Boolean, default: false
  scope :approved, -> { where approved: true }

  need_aftermath :vote

  before_save :update_approved

  def update_approved
    return unless self.group.approved
    self.approved = true
  end
end
