class Member
  include Mongoid::Document

  embedded_in :group, counter_cache: true

  field :user_id, type: String
  field :role, type: Symbol, default: :member

  validates :user_id, presence: true
  validates :role, inclusion: {in: [:member, :admin, :founder]}

  def user
    @user ||= User.find user_id
  end
end
