class Member
  include Mongoid::Document

  embedded_in :group
  field :user_id, type: String
  field :role, type: Symbol, default: :member

  validates :user_id, presence: true
  validates :role, inclusion: {in: [:member, :admin]}
end
