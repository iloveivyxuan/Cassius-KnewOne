require 'rest_client'

class BongClient
  module ResponseCode
    SUCCESS = '200'.freeze
    UNAUTHORIZED = '401'.freeze
    INVALID_ARGS = '402'.freeze
    INVALID_SIGN = '403'.freeze
    NOT_ENOUGH_POINT = '2009'.freeze
    CONSUMING_POINT_ERROR = '2010'.freeze
  end

  RESPONSE_BODY_KEY = 'requestbody'.freeze

  if Rails.env.production?
    SIGN_KEY = '633042b534ff6d85e46d0206aab94e35c1e3c485'
    HOST = 'https://open.bong.cn/1'
  else
    SIGN_KEY = 'ff04f9e0274e33d8c51320b9902234de9067bad2'
    HOST = 'http://open-test.bong.cn/1'
  end

  # _options_ can have the following
  # keys:
  # * *uid*: bong uid
  # * *access_token*: bong access token
  #
  def initialize(options)
    @uid = options[:uid]
    @access_token = options[:access_token]

    @app_id = options[:app_id] || Settings.bong.consumer_key

    @consume_bong_point_api_uri = "#{HOST}/bongInfo/actPoint/consume/#{@uid}?access_token=#{@access_token}"
    @get_bong_point_api_uri = "#{HOST}/bongInfo/actPoint/#{@uid}?access_token=#{@access_token}"
  end

  def current_bong_point
    r = JSON.parse(RestClient.get(@get_bong_point_api_uri))
    if r['code'] == ResponseCode::SUCCESS
      r['value']['point']
    else
      0
    end
  rescue => e
    Rails.logger.info "bong client error in current_bong_point: uid #{@uid} access_token #{@access_token}"
    Rails.logger.info e.message
    nil
  end

  def consume_bong_point_by_order(order, point, options = {})
    params = {
      'actPoint' => point.to_s,
      'comment' => options[:comment] || 'null',
      'orderSN' => order.id.to_s,
      'partner' => @app_id,
      'partnerOrderSN' => order.order_no,
      'subject' => 'KnewOne',
      'userId' => @uid
    }
    uri = "#{@consume_bong_point_api_uri}&sign=#{sign(params)}"

    r = JSON.parse(RestClient.post(uri, params.to_json, :content_type => 'application/json'))

    if r['code'] == ResponseCode::SUCCESS
      {
        code: r['code'],
        bong_point: point,
        success: true,
        raw: r
      }
    else
      {
        code: r['code'],
        success: false,
        raw: r
      }
    end

  rescue => e
    Rails.logger.info "bong client error in consume_bong_point_by_order: uid #{@uid} access_token #{@access_token}"
    Rails.logger.info e.message
    nil
  end

  # _options_ can have the following
  # keys:
  # * *point*: amount of bong point will be consumed
  # * *order_no*: order number of KnewOne side
  # * *comment*: just for comment
  #
  def consume_bong_point(options)
    params = {
      'actPoint' => options[:point].to_s,
      'comment' => options[:comment] || 'null',
      'orderSN' => options[:order_no],
      'partner' => @app_id,
      'partnerOrderSN' => options[:order_no],
      'subject' => 'KnewOne',
      'userId' => @uid
    }
    uri = "#{@consume_bong_point_api_uri}&sign=#{sign(params)}"

    puts uri
    puts params.to_json

    r = JSON.parse(RestClient.post(uri, params.to_json, :content_type => 'application/json'))
    if r['code'] == ResponseCode::SUCCESS
      {
        code: r['code'],
        bong_point: options[:point],
        success: true,
        raw: r
      }
    else
      {
        code: r['code'],
        success: false,
        raw: r
      }
    end
  rescue => e
    Rails.logger.info "bong client error in consume_bong_point: uid #{@uid} access_token #{@access_token}"
    Rails.logger.info e.message
    raise e
    nil
  end

  private

  def sign(params)
    Digest::MD5.hexdigest(params.map do |key, value|
      "#{key}=#{value}"
    end.join('&') + SIGN_KEY)
  end
end
