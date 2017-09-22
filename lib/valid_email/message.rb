class Message
  attr_accessor :message

  def initialize(message)
    @message = message
  end

  def result
    message.respond_to?(:call) ? message.call : message
  end
end