class ThingListBackground
  include Mongoid::Document
  include Mongoid::Timestamps

  field :order, type: Float, default: 0

  mount_uploader :image, ImageUploader
  validates :image, presence: true, file_size: {maximum: 8.megabytes}

  default_scope -> { desc(:order, :created_at) }

  after_destroy do
    ThingList
      .where(background_id: self.id)
      .update_all(background_id: ThingListBackground.first.try(:id))
  end
end
