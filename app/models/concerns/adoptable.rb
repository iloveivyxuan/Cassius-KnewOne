module Adoptable
  extend ActiveSupport::Concern

  included do
    field :adopt, type: String, default: "免费领养"
    field :adopted, type: String, default: "已领养"
    field :apply_to_adopt, type: String, default: "申请领养"
    field :adopt_reason, type: String, default: "申请理由"
    field :confirm_adopt, type: String, default: "确认领养"
    field :share_text, type: String, default: ""
  end

  def adopt_share_text
    return self.share_text unless self.share_text.blank?
    "我在 @KnewOne 免费领养了 #{self.title}：http://knewone.com/things/#{self.slug}"
  end

  def adopt_share_text=(text)
    self.set(share_text: text)
  end
end
