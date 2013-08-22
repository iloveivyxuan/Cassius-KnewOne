# encoding: utf-8
class OrderHistory
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :order

  field :from, type: Symbol, default: :initial
  field :to, type: Symbol
end
