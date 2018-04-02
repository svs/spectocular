require 'net/http'
require 'json'
message = {:channel => '/example_group_started', :data => {a: 32}, :ext => {:auth_token => 'FFF'}}
uri = URI.parse("http://localhost:9292/faye")
Net::HTTP.post_form(uri, :message => message.to_json)
