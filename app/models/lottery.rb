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
  belongs_to :thing, class_name: "Thing", inverse_of: :lotteries
  belongs_to :contribution, class_name: "Thing", inverse_of: :related_lotteries

  attr_writer :winner_link
  validates :date, presence: true
  validate  :check_thing
  validate  :check_contribution
  validate  :check_winner

  default_scope desc(:date)

  def thing_link
    link_to_thing thing
  end

  def thing_link=(link)
    self.thing = parse_thing_link link
  end

  def contribution_link
    link_to_thing contribution
  end

  def contribution_link=(link)
    self.contribution = parse_thing_link link
  end

  def winner_link
    if winner
      @winner_link || user_url(winner, host: Settings.host)
    end
  end

  def winner_link=(link)
    self.winner = parse_user_link(link)
  end

  def check_thing
    errors.add(:thing_link, "无法解析出正确的奖品") if thing.blank?
  end

  def check_contribution
    errors.add(:contribution_link, "无法解析出正确的获奖产品") if contribution.blank?
  end

  def check_winner
    errors.add(:winner_link, "无法解析出用户") if winner.blank?
  end

  private

  def link_to_thing(thing)
    thing_url thing, host: Settings.host if thing
  end

  def parse_thing_link(link)
    return if link.blank?
    reg = Regexp.new "http://(www\.)?#{Settings.host}/things/([\\w-]+)"
    match_data = reg.match(link)
    Thing.find match_data[2] if match_data
  end

  def parse_user_link(link)
    return if link.blank?
    reg = Regexp.new "http://(www\.)?#{Settings.host}/users/(\\h+)"
    match_data = reg.match link
    User.find match_data[2] if match_data
  end
end
