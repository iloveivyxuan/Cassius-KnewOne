# -*- coding: utf-8 -*-
class Guide < Post
  embeds_many :steps

  belongs_to :author, class_name: "User", inverse_of: :post

  validate do |guide|
    errors.add(:base, "Steps are blank") if guide.steps.blank?
  end
end
