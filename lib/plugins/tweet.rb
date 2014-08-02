require 'cinch'
require 'twitter'
require 'formatters/twitter'

# Read tweets from configured accounts periodically
class Tweet
  include Cinch::Plugin
  timer(::Hink.config[:twitter][:interval].to_i * 60, method: :check_tweets)

  @last_update = {}

  def initialize(*args)
    super

    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = Hink.config[:twitter][:consumer_key]
      config.consumer_secret = Hink.config[:twitter][:consumer_secret]
      config.access_token = Hink.config[:twitter][:access_token]
      config.access_token_secret = Hink.config[:twitter][:access_token_secret]
    end
  end

  def check_tweets
    bot.loggers.debug('checking tweets')
    accounts = Hink.config[:twitter][:accounts]
    write_to_channels(accounts.map { |account| check(account) }.flatten)
  end

  private

  def check(account)
    output = tweets(account).map { |item| render_tweet(item) }
    output.compact.reverse
  end

  def write_to_channels(tweets)
    tweets.each do |item|
      bot.channels.uniq.map { |c| c.send(item) }
    end
  end

  def tweets(account)
    @client.user_timeline(account, timeline_options(account)).tap do |tweets|
      @@last_update[account] = tweets.first[:id] if tweets.any?
    end
  end

  def timeline_options(account)
    { since_id: @@last_update[account] }.select { |_k, v| !v.nil? }
  end

  def render_tweet(tweet)
    tweet = Formatters::Twitter.new(tweet, Hink.config[:twitter][:template])
    tweet.extract_hash_info!
    tweet.to_s
  end
end
