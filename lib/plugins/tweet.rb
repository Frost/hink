require "config"
require "twitter"
require "formatters/twitter"

class Tweet
  include Cinch::Plugin
  timer ::Hink.config[:twitter][:interval].to_i*60, method: :check_tweets

  @last_update = {}
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
    Hink.bot.loggers.debug("checking tweets")
    accounts = Hink.config[:twitter][:accounts]
    news = []
    
    accounts.each do |account|
      news << self.class.check_tweets(account)
    end

    news.flatten.each do |item|
      Hink.bot.channels.uniq.map do |c|
        c.send(item)
      end
    end
  end

  def self.check_tweets(account)
    if @last_update[account].nil?
      tweets = Twitter.user_timeline(account)
    else
      tweets = Twitter.user_timeline(account, :since_id => @last_update[account])

      output = tweets.collect do |item|
        item = Formatters::Twitter.new(item, Hink.config[:twitter][:template])
        item.extract_hash_info!
        item.to_s
      end
    end
 
    @last_update[account] = tweets.first[:id] unless tweets.first.nil?
    [*output].reverse.compact
  end
end
