require "cinch"
require "mechanize"
require "rss"
require "config"
require "formatters/feed"

class Feed
  include Cinch::Plugin

  timer ::Hink.config[:feed][:interval].to_i*60, method: :check_news
  @last_update = {}

  def check_news
    Hink.bot.loggers.debug("checking news")
    uris = Hink.config[:feed][:uris]
    news = []

    uris.each do |uri|
      news << self.class.check_news(uri)
    end

    news.flatten.each do |item|
      Hink.bot.channels.map do |c|
        c.send(item)
      end
    end
  end

  def self.check_news(uri)
    agent = Mechanize.new
    feed = agent.get(uri).body
    rss = RSS::Parser.parse(feed)
    @last_update[uri] = Time.now.utc if @last_update[uri].nil?

    items = rss.items.select {|i| i.date.utc > @last_update[uri] }
    @last_update[uri] = rss.items.first.date.utc
    
    output = items.collect do |item|
      item = Formatters::Feed.new(item.to_s, Hink.config[:feed][:template])
      item.parse_response!
      item.to_s
    end

    [*output].compact
  end
end
