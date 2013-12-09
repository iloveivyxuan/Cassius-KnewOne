# encoding: utf-8
class CouponsController < ApplicationController
  prepend_before_action :authenticate_user!

  def index
    @coupons = current_user.coupon_codes
  end

  def bind
    coupon = CouponCode.find_unused_by_code params[:code]

    unless coupon
      return redirect_to coupons_path(redirect_from: params[:redirect_from]), flash: {error: '无效的验证码'}
    end

    unless coupon.bind_user! current_user
      return redirect_to coupons_path(redirect_from: params[:redirect_from]), flash: {error: '这个优惠券已经被绑定'}
    end

    redirect_back_or coupons_path, flash: {success: '添加成功!'}
  end
end
