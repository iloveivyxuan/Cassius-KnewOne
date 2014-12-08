module Fanciable
  extend ActiveSupport::Concern

  included do
    field :fanciers_count, type: Integer, default: 0
    index fanciers_count: -1
  end

  module ClassMethods
    def fancied_as(inverse_name)
      has_and_belongs_to_many :fanciers, class_name: 'User', inverse_of: inverse_name

      class_name = name
      User.class_eval do
        has_and_belongs_to_many inverse_name, class_name: class_name, inverse_of: :fanciers
      end

      define_method :fancy do |user|
        return if fancied?(user)

        self.push(fancier_ids: user.id)
        user.push("#{inverse_name.to_s.singularize}_ids" => self.id)

        set fanciers_count: fanciers.count

        reload
        user.reload
      end

      define_method :unfancy do |user|
        return unless fancied?(user)
        fanciers.delete user
        user.send(inverse_name).delete self
        set fanciers_count: fanciers.count
      end
    end
  end

  def fancied?(user)
    user && fanciers.include?(user)
  end
end
