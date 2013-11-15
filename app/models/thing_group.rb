class ThingGroup < Group
  belongs_to :thing

  has_many :reviews
end
