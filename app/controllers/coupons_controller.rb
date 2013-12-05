# encoding: utf-8
class CouponsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @coupons = current_user.coupon_codes
  end

  def bind
    coupon = CouponCode.find_unused_by_code params[:code]
    return redirect_back_or coupons_path, flash: {error: '无效的验证码'} unless coupon

    return redirect_back_or coupons_path, flash: {error: '这个优惠券已经被绑定'} unless coupon.bind_user! current_user

    redirect_back_or coupons_path, flash: {success: '添加成功!'}
  end
end
