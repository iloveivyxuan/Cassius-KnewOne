module Ratable
  extend ActiveSupport::Concern

  included do
    field :score, type: Integer, default: 0
    validates :score, inclusion: { in: 0..5 }
  end
end
