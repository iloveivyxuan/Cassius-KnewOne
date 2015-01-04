class Coupon
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :coupon_codes

  field :name, type: String
  field :note, type: String
  field :status, type: Symbol, default: :available
  STATUS = {
      disabled: '禁用',
      available: '可用'
  }
  validates :status, presence: true, inclusion: {in: STATUS.keys}
  validates :name, presence: true

  STATUS.keys.each do |s|
    scope s, -> { where status: s }
    define_method :"#{s}?" do
      status == s
    end
  end

  def use_condition(order)
    true # abstract stub
  end

  def take_effect(order, code)
    # abstract stub
  end

  def undo_effect(order)
    # abstract stub
  end

  def usable?(order)
    available? && use_condition(order)
  end

  def generate_code!(params = {})
    params[:code] ||= SecureRandom.uuid[0..7]
    if params[:expires_at].blank?
      params[:expires_at] = 1.year.since.to_date
    end

    coupon_codes.create(params)
  end

  def search(params)
    coupon_codes = self.coupon_codes
    search = case params[:by]
              when 'code'
                Kaminari.paginate_array coupon_codes.where(code: params[:cond]).order_by([:created_at, :desc])
              when 'name'
                user = User.where(name: params[:cond]).first
                Kaminari.paginate_array(coupon_codes.where(user_id: user.id.to_s).order_by([:created_at, :desc])) if user
              else
                coupon_codes.order_by([:created_at, :desc])
              end

    search.page(params[:page]).per(params[:per_page] || 20)
  end
end
