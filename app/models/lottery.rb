# -*- coding: utf-8 -*-
class Lottery
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  include Rails.application.routes.url_helpers

  field :date, type: Date
  field :name, type: String
  field :phone, type: Integer
  field :address, type: String
  field :is_delivered, type: Boolean
  field :delivery, type: String

  belongs_to :winner, class_name: "User"
  belongs_to :thing

  attr_writer :winner_link
  validates :date, presence: true
  validate  :check_thing
  validate  :check_winner

  default_scope desc(:date)

  def thing_link
    thing_url thing, host: Settings.host if thing
  end

  def thing_link=(link)
    return if link.blank?
    reg = Regexp.new "http://#{Settings.host}/things/([\\w-]+)"
    match_data = reg.match(link)
    self.thing = Thing.find match_data[1] if match_data
  end

  def winner_link
    if winner
      @winner_link || user_url(winner, host: Settings.host)
    end
  end

  def check_thing
    errors.add(:thing_link, "无法解析出正确的商品") if thing.blank?
  end

  def check_winner
    return if @winner_link.blank?
    reg = Regexp.new "http://#{Settings.host}/users/(\\h+)"
    match_data = reg.match @winner_link
    if match_data
      self.winner = User.find match_data[1]
      errors.add(:winner_link, "未找到指定用户") unless self.winner
    else
      errors.add(:winner_link, "无法解析出用户")
    end
  end
end
