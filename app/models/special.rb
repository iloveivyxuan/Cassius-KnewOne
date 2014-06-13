class Special < Post
  embeds_many :special_subjects
  accepts_nested_attributes_for :special_subjects, allow_destroy: true
end
