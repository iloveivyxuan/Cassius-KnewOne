class ApiRequestError < StandardError
  attr_reader :code, :message, :status, :extra

  def initialize(code, message, status, extra = {})
    @code, @message, @status, @extra = code, message, status, extra
  end
end
