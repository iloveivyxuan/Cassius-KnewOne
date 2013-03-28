class Group
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  belongs_to :founder, class_name: "User", inverse_of: :found_group

  has_and_belongs_to_many :members, class_name: "User", inverse_of: :groups
  has_many :topics

  default_scope desc(:created_at)
end
