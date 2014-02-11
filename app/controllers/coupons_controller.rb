# encoding: utf-8
class CouponsController < ApplicationController
  prepend_before_action :require_signed_in
  layout 'settings', only: [:index]

  def index
    @coupons = current_user.coupon_codes
  end

  def bind
    coupon = CouponCode.find_unused_by_code params[:code]

    unless coupon
      return redirect_to coupons_path(redirect_from: params[:redirect_from]), flash: {msg: '无效的验证码', status: 'error'}
    end

    if coupon.expired?
      return redirect_to coupons_path(redirect_from: params[:redirect_from]), flash: {msg: '这个优惠券已经过期', status: 'error'}
    end

    unless coupon.bind_user! current_user
      return redirect_to coupons_path(redirect_from: params[:redirect_from]), flash: {msg: '这个优惠券已经被绑定', status: 'error'}
    end

    redirect_back_or coupons_path, flash: {msg: '添加成功!', status: 'success'}
  end
end
