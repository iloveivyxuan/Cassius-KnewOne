class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :commented_at, type: DateTime

  belongs_to :author, class_name: "User", inverse_of: :post

  embeds_many :comments

  validates :title, presence: true

  after_create :update_commented_at

  def update_commented_at
    update_attribute :commented_at, created_at
  end
end
