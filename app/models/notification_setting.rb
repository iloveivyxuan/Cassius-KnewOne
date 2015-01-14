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

  # thing
  field :stock, type: Symbol, default: :all
  field :new_review, type: Symbol, default: :all
  field :new_feeling, type: Symbol, default: :all
  field :new_topic, type: Symbol, default: :all

  # reply
  field :comment, type: Symbol, default: :all
  field :topic, type: Symbol, default: :all
  field :review, type: Symbol, default: :all
  field :feeling, type: Symbol, default: :all
  field :list_item, type: Symbol, default: :all

  # friend
  field :following, type: Symbol, default: :all
  field :weibo_friend_joined, type: Symbol, default: :all

  # fancy
  field :love_feeling, type: Symbol, default: :all
  field :love_review, type: Symbol, default: :all
  field :love_topic, type: Symbol, default: :all
  field :fancy_thing, type: Symbol, default: :all
  field :fancy_list, type: Symbol, default: :all

  validates :stock, :new_review, :new_feeling, :new_topic,
  :comment, :topic, :review, :feeling, :list_item,
  :following, :weibo_friend_joined,
  :love_feeling, :love_review, :love_topic, :fancy_thing, :fancy_list, presence: true

  validates :new_review, :new_feeling, :new_topic, :comment, :topic, :review, :feeling, :list_item,
            inclusion: {in: SCOPE_OPTIONS.keys}
  validates :stock, :following, :weibo_friend_joined, :love_feeling, :love_review, :love_topic, :fancy_thing, :fancy_list,
            inclusion: {in: BOOL_OPTIONS.keys}
end
