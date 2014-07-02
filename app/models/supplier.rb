class Supplier
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :contact, type: String
  field :description, type: String
  field :url, type: String, default: ""
  field :thing_title, type: String, default: ""
  field :note, type: String, default: ""
  field :user_id, type: String

  def user
    @user ||= (self.user_id ? User.find(self.user_id) : nil)
  end

  validates :name, presence: true
  validates :contact, presence: true
  validates :description, presence: true

  default_scope -> { desc(:created_at) }
end
