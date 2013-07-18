module CustomerService
  class Dialog
    include Mongoid::Document
    include Mongoid::Timestamps

    field :meta, :type => String
    field :body, :type => String

    belongs_to :user
    belongs_to :sender, :class_name => 'User'

    validates :body, :user, :sender, :presence => true

    attr_accessible :body, :meta

    def meta
      @meta ||= JSON.parse super unless super.blank?
    end

    def meta=(opt = {})
      super(opt.to_json)
    end
  end
end
