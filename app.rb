require 'sinatra'
require 'net/http'

set :server, 'thin'

base_url = ''

get '/' do

    # do a YoAll
    status = Net::HTTP.post_form(URI.parse(
        'https://api.justyo.co/yoall/'),
        {
            'api_token' => ENV['YO_KEY'],
            'link' => 'http://yotext.co/show/?text=COFFEE TIME?'
        }
    )

    # terse status response
    if status
        'success'
    else
        'failed to YoAll'
    end

end
