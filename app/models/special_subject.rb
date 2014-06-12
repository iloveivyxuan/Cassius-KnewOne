class SpecialSubject
  include Mongoid::Document

  embedded_in :special

  field :thing_id, type: String
  field :subtitle, type: String
  field :content, type: String

  def thing
    @_thing ||= Thing.or({id: self.thing_id}, {slugs: self.thing_id}).first
  end
end
