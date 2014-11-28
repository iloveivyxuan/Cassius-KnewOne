module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    after_save    { Indexer.perform_async(:index, self.class.to_s,  self.id.to_s) }
    after_destroy { Indexer.perform_async(:delete, self.class.to_s, self.id.to_s) }
  end

  def as_indexed_json
    {}
  end
end
