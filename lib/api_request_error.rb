class ApiRequestError < StandardError
  attr_reader :code, :message, :status

  def initialize(code, message, status)
    @code, @message, @status = code, message, status
  end
end
