# encoding: utf-8
class Invoice
  include Mongoid::Document

  embedded_in :user
  embedded_in :order

  field :kind, type: String, default: '普通发票'
  field :title, type: String, default: '个人'

  KINDS = %w(普通发票)

  validates :kind, :title, presence: true
  validates :kind, inclusion: {in: KINDS, allow_blank: false}
end
