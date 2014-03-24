class Topic < Post
  include Aftermath

  field :is_top, type: Boolean, default: false

  belongs_to :group, counter_cache: true

  default_scope -> { desc(:is_top, :commented_at) }

  def official_cover(version = :small)
    src = self.content.scan(/<img src=\"(.+?)\"/).try(:[], 0).try(:[], 0)
    return nil unless src.present? and src[0..23] == 'http://image.knewone.com'

    src.gsub(/!.*$/, "!#{version}")
  end

  need_aftermath :create, :destroy
end
