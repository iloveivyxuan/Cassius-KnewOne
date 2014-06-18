module Rankable
  extend ActiveSupport::Concern

  included do
    field :heat, type: Float
    index heat: -1

    scope :hot, -> { desc(:heat) }
  end

  def freezing_coefficient
    days_after_created = 1.0 * (Time.now - created_at) / 1.day
    (days_after_created + 1) ** -1.4
  end

  def calculate_heat
    raise 'Not implemented'
  end

  module ClassMethods
    def update_all_heat_since(time)
      where(:created_at.gt => time).each do |x|
        x.update(heat: x.calculate_heat)
      end
    end
  end
end
