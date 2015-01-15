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

  MENTION = [:comment, :topic, :review, :feeling, :list_item]

  TYPES.each do |key, type|
    field key, type: Symbol, default: :all
    options = (type == :scope) ? SCOPE_OPTIONS : BOOL_OPTIONS

    validates key, presence: true
    validates key, inclusion: { in: options.keys }
  end

  # duplicated field
  field :mention, type: Symbol, default: :all

  before_save :set_mention

  private

  def set_mention
    return unless mention_changed?
    MENTION.each { |key| set(key => mention) }
  end
end
