require 'sinatra'
require 'net/http'

set :server, 'thin'

base_url = ''

get '/' do
    Net::HTTP.post_form(URI.parse(
        'https://api.justyo.co/yoall/'),
        {'api_token' => ENV['YO_KEY']}
    )
end
