class CategoryReference
  include Mongoid::Document

  embedded_in :user

  field :name, type: String
  field :count, type: Integer, default: 1

  default_scope -> { desc(:count) }
end
