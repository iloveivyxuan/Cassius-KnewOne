class CustomerService::Ticket
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body, type: String

  belongs_to :user

  validates :body, :presence => true
end
