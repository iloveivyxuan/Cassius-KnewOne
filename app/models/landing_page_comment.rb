class LandingPageComment
  include Mongoid::Document

  embedded_in :landing_page

  belongs_to :user, inverse_of: nil

  field :body, type: String
end
