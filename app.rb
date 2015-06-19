require 'sinatra'
require 'net/http'
require 'redis'

set :server, 'thin'
base_url = ''
redis = Redis.new(:url => ENV['REDISTOGO_URL'])

get '/' do

    if params.key?('username')
        logger.info "adding user to redis"
        redis.sadd('people', params['username'])

        # never mind this coffee session if nobody responds in time
        redis.expire('people', 60)

    end

    # return name or count depending on card
    headcount = redis.scard('people')
    subject =
        if headcount < 2
            redis.srandmember('people')
        else
            headcount.to_s + "people"
        end

    text = "#{subject} would like coffee!"

    # do a YoAll
    status = Net::HTTP.post_form(URI.parse(
        'https://api.justyo.co/yoall/'),
        {
            'api_token' => ENV['YO_KEY'],
            'link' => "http://yotext.co/show/?text=" + text,
        }
    )

    # terse status response
    if status
        'success'
    else
        'failed to YoAll'
    end

end
