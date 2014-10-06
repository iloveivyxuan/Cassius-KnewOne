module BongPointConsumable
  extend ActiveSupport::Concern

  included do
    field :minimal_bong_point, type: Integer, default: 0
    field :maximal_bong_point, type: Integer, default: 0

    validates :minimal_bong_point, :maximal_bong_point, presence: true, numericality: { greater_than_or_equal_to: 0 }

    validate do
      if self.minimal_bong_point > self.maximal_bong_point
        self.errors.add :maximal_bong_point, '最大值不能小于最小值'
      end

      if self.minimal_bong_point > self.price
        self.errors.add :minimal_bong_point, '不能超过商品金额'
      end

      if self.maximal_bong_point > self.price
        self.errors.add :maximal_bong_point, '不能超过商品金额'
      end
    end
  end

  def fixed_bong_point?
    (self.minimal_bong_point == maximal_bong_point) && self.minimal_bong_point != 0
  end

  def consume_bong_point_only?
    fixed_bong_point? && self.minimal_bong_point == self.price
  end

  def can_consume_bong_point?
    self.maximal_bong_point > 0
  end
end
