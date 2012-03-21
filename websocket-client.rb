# gem install em-websocket
require 'rubygems'
require 'em-websocket'

class WSConnection < EventMachine::WebSocket::Connection
  @@clients  ||= []
  def trigger_on_open
    @@clients ||= []
    @@clients << self
  end

  def trigger_on_message(msg)
    @@clients.each do |c|
      c.send msg
    end

  end

  def trigger_on_close
    @@clients.delete self
  end

  # Static
  def self.send_status(string)
    @@clients.each do |c|
      c.send string
    end
  end

end

EventMachine.run do
  EventMachine.start_server("192.168.35.25", 8000, WSConnection, {:debug => true})
#  EventMachine::PeriodicTimer.new(5) do
#    puts "the time is #{Time.now}"
#    WSConnection::send_status("the time is #{Time.now}")
#  end
end
