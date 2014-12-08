class Dialog
  include Mongoid::Document
  include Mongoid::Timestamps::Updated

  field :unread_count, type: Integer, default: 0
  belongs_to :sender, class_name: "User", inverse_of: nil
  belongs_to :user, index: true
  embeds_many :private_messages do
    def unread
      where(is_new: true, is_in: true)
    end
  end

  default_scope -> { desc(:updated_at) }

  def reset
    if private_messages.present?
      self.update_attributes(
                        updated_at: private_messages.first.created_at,
                        unread_count: private_messages.unread.count
                        )
    else
      self.destroy
    end
  end

  def newest_message
    @newest_message ||= private_messages.first
  end

end
