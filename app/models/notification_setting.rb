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

  TYPES = {
    :new_review => :scope,
    :new_feeling => :scope,
    :new_topic => :scope,
    :comment => :scope,
    :topic => :scope,
    :review => :scope,
    :feeling => :scope,
    :list_item => :scope,

    :stock => :bool,
    :following => :bool,
    :weibo_friend_joined => :bool,
    :love_feeling => :bool,
    :love_review => :bool,
    :love_topic => :bool,
    :fancy_thing => :bool,
    :fancy_list => :bool
  }

  TYPES.each do |key, type|
    field key, type: Symbol, default: :all
    options = (type == :scope) ? SCOPE_OPTIONS : BOOL_OPTIONS

    validates key, presence: true
    validates key, inclusion: { in: options.keys }
  end
end
