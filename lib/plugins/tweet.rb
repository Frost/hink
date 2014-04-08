require "cinch"
require "twitter"
require "formatters/twitter"

class Tweet
  include Cinch::Plugin
  timer ::Hink.config[:twitter][:interval].to_i*60, method: :check_tweets

  @@last_update = {}
  def initialize(*args)
    super

    Twitter.configure do |config|
      config.consumer_key = Hink.config[:twitter][:consumer_key]
      config.consumer_secret = Hink.config[:twitter][:consumer_secret]
      config.oauth_token = Hink.config[:twitter][:oauth_token]
      config.oauth_token_secret = Hink.config[:twitter][:oauth_token_secret]
    end
  end

  def check_tweets
    bot.loggers.debug("checking tweets")
    accounts = Hink.config[:twitter][:accounts]
    write_to_channels(accounts.collect {|account| check(account) }.flatten)
  end

 private

  def check(account)
    output = tweets(account).collect { |item| render_tweet(item) }
    return output.compact.reverse
  end

  def write_to_channels(tweets)
    tweets.each do |item|
      bot.channels.uniq.map {|c| c.send(item) }
    end
  end

  def tweets(account)
    tweets = Twitter.user_timeline(account, timeline_options(account)).compact
    @@last_update[account] = tweets.first[:id] unless tweets.first.nil?
    return tweets
  end

  def timeline_options(account)
    { since_id: @@last_update[account] }.select {|k,v| !v.nil? }
  end

  def render_tweet(tweet)
    tweet = Formatters::Twitter.new(tweet, Hink.config[:twitter][:template])
    tweet.extract_hash_info!
    tweet.to_s
  end
end
