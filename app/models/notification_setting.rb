#encoding: utf-8
class NotificationSetting
  include Mongoid::Document
  belongs_to :user

  SCOPE_OPTIONS = {
      :none => '禁止',
      :followed => '仅我关注的',
      :all => '任何人'
  }

  field :stock_notification, type: Boolean, default: true
  field :new_review_notification, type: Symbol, default: :all
  field :comment_notification, type: Symbol, default: :all

  validates :stock_notification, :new_review_notification, :comment_notification, presence: true
  validates :new_review_notification, :comment_notification,
            inclusion: {in: SCOPE_OPTIONS.keys}
end
