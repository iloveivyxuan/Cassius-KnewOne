class Member
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  embedded_in :group, counter_cache: true

  field :user_id, type: String
  field :role, type: Symbol, default: :member

  validates :user_id, presence: true
  validates :role, inclusion: {in: [:member, :admin, :founder]}

  default_scope -> { desc(:created_at) }

  def user
    @user ||= User.find user_id.to_s
  end
end
