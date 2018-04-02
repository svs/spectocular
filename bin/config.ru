require 'faye'
Faye::WebSocket.load_adapter('thin')

bayeux = Faye::RackAdapter.new(:mount => '/faye', :timeout => 10)
bayeux.on(:handshake) do |c|
  p c
end
bayeux.on(:publish) do |m|
  p m
end
run bayeux
