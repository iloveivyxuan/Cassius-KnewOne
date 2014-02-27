class PrivateMessage
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :content, type: String
  field :is_new, type: Boolean, default: false
  field :is_in, type: Boolean, default: false

  embedded_in :dialog
end
