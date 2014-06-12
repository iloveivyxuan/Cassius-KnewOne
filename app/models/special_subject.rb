class SpecialSubject
  include Mongoid::Document

  embedded_in :special

  belongs_to :thing

  field :subtitle, type: String
  field :content, type: String
end
