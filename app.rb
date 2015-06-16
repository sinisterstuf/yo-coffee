require 'sinatra'

set :server, 'thin'

base_url = ''

get '/' do
    "COFFEE TIME!"
end
