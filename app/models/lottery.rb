# -*- coding: utf-8 -*-
class Lottery
  include Mongoid::Document
  include Rails.application.routes.url_helpers

  field :date, type: Date
  field :name, type: String
  field :phone, type: Integer
  field :address, type: String
  field :is_delivered, type: Boolean
  field :delivery, type: String

  belongs_to :winner, class_name: "User"
  belongs_to :thing, class_name: "Thing", inverse_of: :lotteries
  belongs_to :contribution, class_name: "Post", inverse_of: :related_lotteries

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
    case contribution.class
    when Thing
      link_to_thing contribution
    when Review
      link_to_review contribution
    end
  end

  def contribution_link=(link)
    self.contribution = parse_review_link(link) || parse_thing_link(link)
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
    errors.add(:thing_link, "无法解析出奖品") if thing.blank?
  end

  def check_contribution
    errors.add(:contribution_link, "无法解析出获奖原因") if contribution.blank?
  end

  def check_winner
    errors.add(:winner_link, "无法解析出用户") if winner.blank?
  end

  private

  def link_to_thing(thing)
    thing_url thing, host: Settings.host if thing
  end

  def link_to_review(review)
    thing_review_url review.thing, review, host: Settings.host if review
  end

  def parse_thing_link(link)
    id = parse_link link, "/things/([\\w-]+)"
    id and Thing.find(id)
  end

  def parse_review_link(link)
    id = parse_link link, "/things/[\\w-]+/reviews/(\\h+)"
    id and Review.find(id)
  end

  def parse_user_link(link)
    id = parse_link link, "/users/(\\h+)"
    id and User.find(id)
  end

  def parse_link(link, path_reg)
    return if link.blank?
    reg = Regexp.new "http://(www\.)?#{Settings.host}#{path_reg}"
    match_data = reg.match link
    match_data and match_data[2]
  end
end
