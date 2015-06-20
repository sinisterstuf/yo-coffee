require 'sinatra'
require 'net/http'
require 'redis'

set :server, 'thin'
base_url = ''
redis = Redis.new(:url => ENV['REDISTOGO_URL'])

get '/' do

    logger.info "got request"

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
            logger.info "personal subject"
            redis.srandmember('people')
        else
            logger.info "cardinal subject"
            headcount.to_s + "people"
        end

    text = "#{subject} would like coffee!"
    logger.info text

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
        logger.info 'success'
        'success'
    else
        logger.info 'failed to YoAll'
        'failed to YoAll'
    end

end
