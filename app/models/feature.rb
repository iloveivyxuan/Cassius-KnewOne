class Feature < Post
  field :priority, type: Integer, default: 0

  field :fanciers_count, type: Integer, default: 0
  has_and_belongs_to_many :fanciers, class_name: "User", inverse_of: :fancy_features
  include Fancy

  default_scope desc(:priority)

  belongs_to :thing
end
