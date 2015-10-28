YOCOFFEE
=========

*Yo to let each other know it's time to go for coffee together!*

**YOCOFFEE** is a step up from the regular YoAll: it counts the number
of people who Yo it within 2 minutes and sends everyone a message about
who wants to go for coffee.

Usage
-----

1. install [Yo](https://www.justyo.co/)
2. add **YOCOFFEE**
3. tap when you want to go for a coffee
4. your friends Yo back within 2 minutes
5. subscribers get a Yo telling them who wants to go

Developing
----------

Set up environment:

    rvm 2.2.2
    bundle install

Start web app:

    bundle exec ruby app.rb

The app stores the number of users in Redis for 2 minutes.  It is
intended to be run in Heroku with Redis2go.  If you run it locally, you
should have Redis running and set these environment variables:

 * `REDISTOGO_URL` to store Yo counts in Redis
 * `YO_KEY` to send YoAll via the Yo API
 * `RUN_MODE` set it to "TEST" to Yo to `TEST_USER` instead of YoAll
 * `TEST_USER` a registered user to send test Yo to

---
Copyright (C) 2015 Siôn le Roux (see [LICENSE.txt](LICENSE.txt) for more information)
