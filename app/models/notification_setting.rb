#encoding: utf-8
class NotificationSetting
  include Mongoid::Document
  embedded_in :user

  SCOPE_OPTIONS = {
      :none => '禁止',
      :following => '仅我关注的',
      :all => '任何人'
  }

  BOOL_OPTIONS = {
      :none => '禁止',
      :all => '允许'
  }

  field :stock, type: Symbol, default: :all
  field :new_review, type: Symbol, default: :all
  field :comment, type: Symbol, default: :all

  validates :stock, :new_review, :comment, presence: true
  validates :new_review, :comment,
            inclusion: {in: SCOPE_OPTIONS.keys}
  validates :stock,
            inclusion: {in: BOOL_OPTIONS.keys}
end
