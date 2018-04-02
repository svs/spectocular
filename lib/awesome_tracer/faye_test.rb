require 'faye'
require 'eventmachine'
require 'pry-byebug'
EM.run {
  client = Faye::Client.new('http://localhost:9292/faye')

  publication = client.publish('/example_group_started', 'text' => 'Hello world')
  p publication.inspect
  publication.callback do
    puts 'Message received by server!'
    EM.stop_event_loop

  end

  publication.errback do |error|
    puts 'There was a problem: ' + error.message
    EM.stop_event_loop

  end


}
