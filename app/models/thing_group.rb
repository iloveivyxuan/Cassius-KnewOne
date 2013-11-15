class ThingGroup < Group
  has_one :thing

  has_many :reviews
end
