module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    after_save do
      if searchable_fields_changed?
        Indexer.perform_async(:index, self.class.to_s, self.id.to_s)
      end
    end

    after_destroy { Indexer.perform_async(:delete, self.class.to_s, self.id.to_s) }
  end

  module ClassMethods
    def searchable_fields(fields)
      define_method :searchable_fields_changed? do
        fields.any? { |field| changed.include?(field.to_s) }
      end

      define_method :as_indexed_json do
        as_json(only: fields)
      end
    end
  end
end
