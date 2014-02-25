class PrivateDialog
  include Mongoid::Document
  include Mongoid::Timestamps::Updated

  field :unread_count, type: Integer, default: 0
  belongs_to :sender, class_name: "User", inverse_of: nil
  belongs_to :user
  embeds_many :private_messages

  default_scope -> { desc(:updated_at) }
end
