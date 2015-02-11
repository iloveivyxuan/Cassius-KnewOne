class Relationship
  include Mongoid::Document

  belongs_to :user, index: true
  has_and_belongs_to_many :followings, class_name: 'User', inverse_of: nil
  has_and_belongs_to_many :followers, class_name: 'User', inverse_of: nil

  validates :user_id, presence: true, uniqueness: true
end
