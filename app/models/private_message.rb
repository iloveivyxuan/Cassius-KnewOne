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

  after_create do
    PrivateMessageEmailWorker.perform_in(1.hours.from_now, self.dialog.id.to_s)
  end
end
