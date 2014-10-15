class PrivateMessage
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :content, type: String
  field :is_new, type: Boolean, default: false
  field :is_in, type: Boolean, default: false

  embedded_in :dialog

  validates :content, presence: true

  default_scope -> { desc(:created_at) }

  after_create -> { dialog.reset }
  after_destroy -> { dialog.reset }

  def is_for_flagged?
    self.dialog.sender_id.to_s == '543c956231302d1015600100' and self.content.include?("举报")
  end

end
