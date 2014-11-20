module Rankable
  extend ActiveSupport::Concern

  included do
    field :heat, type: Float, default: 0
    index heat: -1

    scope :hot, -> { desc(:heat) }

    before_update do
      self.heat = calculate_heat
    end
  end

  def birth_time
    created_at
  end

  def half_life
    1.day
  end

  def freezing_coefficient
    1 / 2 ** ((Time.now - birth_time) / half_life)
  end

  def calculate_heat
    raise 'Not implemented'
  end

  module ClassMethods
    def update_all_heat_since(time)
      where(:created_at.gt => time).no_timeout.each do |x|
        x.set(heat: x.calculate_heat)
      end
    end
  end
end
