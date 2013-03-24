class Link < Post
  field :url, type: String, default: ""

  belongs_to :thing

  has_and_belongs_to_many :diggers, class_name: "User", inverse_of: nil

  validates :url, presence: true

  default_scope desc(:updated_at)

  def digg(user)
    digged?(user) and return
    diggers << user
  end

  def digged?(user)
    diggers.include? user
  end
end
