require 'sinatra'
require 'net/http'
require 'redis'

# Set up Sinatra
set :server, 'thin'
base_url = ''

# Set up Redis
redis = Redis.new(:url => ENV['REDISTOGO_URL'])

# Constants
yoapi_url  = 'https://api.justyo.co/'
yotext_url = 'http://yotext.co/show/?text='
yotype = 'yoall'
postdata = { api_token: ENV['YO_KEY'] }

# Test mode sends Yo to test user instead of YoAll
if ENV['RUN_MODE'] == 'TEST'
    logger.info "test mode: only Yo to #{ENV['TEST_USER']}"
    yotype = 'yo'
    postdata[:username] = ENV['TEST_USER']
end

redis.set('foo', 'bar')
puts redis.get('foo')

get '/' do

    logger.info "got request"

    if params.key?('username')
        logger.info "adding user to redis"
        redis.sadd('people', params['username'])

        # never mind this coffee session if nobody responds in time
        redis.expire('people', 60)
    end

    # return name or count depending on cardinality
    headcount = redis.scard('people')
    subject =
        if headcount < 2
            redis.srandmember('people')
        elsif headcount < 3
            redis.srandmember('people', 2).join(' and ')
        else
            logger.info "cardinal subject"
            "#{headcount} people"
        end

    text = "#{subject} would like coffee!"
    logger.info text
    postdata[:link] = yotext_url + text

    # send the Yo
    status = Net::HTTP.post_form(URI.parse(yoapi_url + yotype + '/'), postdata)

    # terse status response
    if status
        logger.info 'success'
        'success'
    else
        logger.info 'failed to YoAll'
        'failed to YoAll'
    end

end
