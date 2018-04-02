require 'sinatra'
require 'slim'
get '/files' do
  [200,File.read(params[:name])]
end

get '/' do
  slim :layout
end
