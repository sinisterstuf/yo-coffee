require 'sinatra'
require 'net/http'
require 'redis'

# Set up Sinatra
set :server, 'thin'
base_url = ''

# Set up Redis
redis = Redis.new(:url => ENV['REDISTOGO_URL'])

# Get colour list
require_relative 'colors'

# Constants
yoapi_url  = 'https://api.justyo.co/'
yotext_url = ENV['OWN_URL'] + '/show?text='
yotype = 'yoall'
postdata = { api_token: ENV['YO_KEY'] }

# Test mode sends Yo to test user instead of YoAll
if ENV['RUN_MODE'] == 'TEST'
    yotype = 'yo'
    postdata[:username] = ENV['TEST_USER']
end

get '/' do

    logger.info "got request"
    logger.info "#{ENV['RUN_MODE']} mode"
    logger.info "only Yo to #{ENV['TEST_USER']}" if ENV['RUN_MODE'] == 'TEST'

    if params.key?('username')
        logger.info "adding user to redis"
        redis.sadd('people', params['username'])

        # never mind this coffee session if nobody responds in time
        redis.expire('people', 60)
    end

    # return name or count depending on cardinality
    headcount = redis.scard('people')
    subject =
        if headcount < 1
            "nobody"
        elsif headcount < 2
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

get '/show' do
    logger.info "got text request: #{params['text']}"
    return erb :show, :locals => {
        :text => params['text'],
        :color => colors.sample
    }
end
