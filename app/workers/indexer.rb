class Indexer
  include Sidekiq::Worker
  sidekiq_options queue: 'elasticsearch', retry: false, backtrace: true

  Logger = Sidekiq.logger.level == Logger::DEBUG ? Sidekiq.logger : nil
  Client = Elasticsearch::Client.new host: (ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200'), logger: Logger

  def perform(operation, klass_name, record_id)
    klass = klass_name.constantize
    index_name = klass.index_name
    document_type = klass.document_type

    case operation.to_s
    when /index/
      body = klass.find(record_id).as_indexed_json
      Client.index(index: index_name, type: document_type, id: record_id, body: body)
    when /delete/
      Client.delete(index: index_name, type: document_type, id: record_id)
    else
      raise ArgumentError, "Unknown operation '#{operation}'"
    end
  end
end
