class Blacklist
  include Mongoid::Document

  field :word, type: String, default: ""
end
