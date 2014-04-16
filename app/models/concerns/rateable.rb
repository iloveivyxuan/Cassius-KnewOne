module Rateable
  extend ActiveSupport::Concern

  included do
    field :score, type: Integer, default: 0

    validate do |obj|
      unless (0..5).include? obj.score
        errors.add :score, "Score should be in [0..5]"
      end
    end
  end
end
