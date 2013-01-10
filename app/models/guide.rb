# -*- coding: utf-8 -*-
class Guide < Post
  embeds_many :steps
  accepts_nested_attributes_for :steps, allow_destroy: true

  validate do |guide|
    errors.add(:base, "Steps are blank") if guide.steps.blank?
  end
end
