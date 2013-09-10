# encoding: utf-8
class OrderHistory
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :order

  field :from, type: Symbol, default: :initial
  field :to, type: Symbol
end
