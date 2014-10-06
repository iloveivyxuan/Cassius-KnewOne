class Kind
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes

  include BongPointConsumable

  embedded_in :thing

  field :stock, type: Integer, default: 0
  field :sold, type: Integer, default: 0
  field :title, type: String, default: ''
  field :note, type: String, default: ''
  field :photo_number, type: Integer, default: 0
  field :price, type: BigDecimal, default: 0.0
  field :max_per_buy, type: Integer, default: 0

  field :stage, type: Symbol, default: :stock
  field :estimates_at, type: DateTime

  STAGES = {
      pre_order: "预售",
      stock: "现货",
      ship: "即将到货",
      exclusive: "限量",
      hidden: "下架"
  }
  validates :stage, inclusion: {in: STAGES.keys}

  validates :stock, numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0
  }

  validates :sold, numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0
  }

  validates :price, numericality: {
      greater_than_or_equal_to: 0
  }

  def has_stock?
    stock > 0
  end

  def safe_destroy?
    !Order.where('order_items.kind_id' => self.id.to_s).exists?
  end

  def max_buyable
    max = if max_per_buy.nil? || max_per_buy == 0
            stock
          else
            [stock, max_per_buy].compact.min
          end
    max < 0 ? 0 : max
  end
end
