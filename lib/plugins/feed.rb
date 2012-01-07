require "cinch"
require "mechanize"
require "rss"
require "config"
require "formatters/feed"

class Feed
  include Cinch::Plugin

  timer ::Hink.config[:feed][:interval].to_i*60, method: :check_news

  def check_news
    Hink.bot.logger.debug("checking news")
    news = self.class.check_news

    news.each do |item|
      Hink.bot.channels.map do |c|
        c.send(item)
      end
    end
  end

  def self.check_news
    agent = Mechanize.new
    feed = agent.get(Hink.config[:feed][:uri]).body
    rss = RSS::Parser.parse(feed)
    threshold = (Time.now - 60*Hink.config[:feed][:interval].to_i).utc
    items = rss.items.select do |i| 
      i.date >= threshold
    end
    
    output = items.collect do |item|
      item = Formatters::Feed.new(item.to_s, Hink.config[:feed][:template])
      item.parse_response!
      item.to_s
    end

    [*output].compact
  end
end
