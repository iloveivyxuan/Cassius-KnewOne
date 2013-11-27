# encoding: utf-8
class CouponsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @coupons = current_user.coupons
  end

  def bind
    coupon = Coupon.find_available_by_code params[:code]
    return redirect_to coupons_path, flash: {error: '无效的验证码'} unless coupon

    return redirect_to coupons_path, flash: {error: '这个优惠券已经被绑定'} unless coupon.bind_user! current_user

    redirect_to coupons_path, flash: {success: '添加成功!'}
  end
end
