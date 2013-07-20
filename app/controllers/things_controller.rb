# -*- coding: utf-8 -*-
require 'rest_client'
require 'open-uri'
class ThingsController < PostsController
  after_filter :store_location, only: [:show]

  def index
    scope = case params[:sort]
            when "self_run"
              Thing.published.where(is_self_run: true)
            when "fancy"
              Thing.unscoped.published.desc(:fanciers_count)
            when "shop"
              Thing.ne(shop: "")
            else
              Thing.published
            end

    @things = scope.page(params[:page]).per(12)

    respond_to do |format|
      format.html
      format.atom
      format.json
    end
  end

  def admin
    if params[:can_buy]
      @things = Thing.nor(shop: "", oversea_shop: "").page params[:page]
    else
      @things = Thing.page params[:page]
    end
  end

  def new
    @thing = Thing.new
  end

  def create
    @thing = Thing.new params[:thing].merge(author: current_user)
    if @thing.save
      @thing.fancy current_user
      redirect_to @thing, flash: {provider_sync: params[:provider_sync]}
    else
      render 'new'
    end
  end

  def show
    @thing = Thing.find(params[:id]) || not_found
    read_comments @thing
    render layout: 'thing'
  end

  def edit
    @photos = @thing.photos.map(&:to_jq_upload)
    render 'new'
  end

  def update
    if @thing.update_attributes(params[:thing])
      redirect_to @thing
    else
      render 'new'
    end
  end

  def destroy
    @thing.destroy
    redirect_to root_path
  end

  def fancy
    if @thing.fancied? current_user
      @thing.unfancy current_user
    else
      @thing.fancy current_user
    end

    respond_to do |format|
      format.html { redirect_to @thing }
      format.js
    end
  end

  def own
    if @thing.owned? current_user
      @thing.unown current_user
    else
      @thing.own current_user
    end

    respond_to do |format|
      format.html { redirect_to @thing }
      format.js
    end
  end

  def buy
    redirect_to @thing.shop
  end

  def buy_package
    redirect_to @thing.packages[params[:index].to_i].shop
  end

  def comments
    read_comments @thing
    render layout: 'thing'
  end

  def pro_edit
  end

  def pro_update
    if @thing.update_attributes(params[:thing])
      redirect_to @thing
    else
      render 'pro_edit'
    end
  end

  def weixin_qr
    rand = %w( 4 3 1 2 9 8 2 5 4 0 5 7 7 6 5 ).shuffle.join('')
    res = RestClient.get "https://open.weixin.qq.com/qr/set/?a=1&title=#{URI::encode(@thing.title)}&url=#{thing_url(@thing)}&img=#{@thing.cover.url}&appid=&r=0.#{rand}"
    url = "http://open.weixin.qq.com/qr/#{/showWxBox\("(.+)"\)/.match(res)[1]}#wechat_redirect"
    file = Rails.root.join("tmp/#{@thing.id}.png")

    `qrencode -o #{file} '#{url}'`
    if $?.success?
      expires_in 15.minutes
      send_data File.read(file), :disposition => 'inline', :type => 'image/png'
    else
      render :text => 'error, retry.'
    end
  end
end
