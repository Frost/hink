require 'cinch'
require 'mechanize'
require 'rss'
require 'config'
require 'formatters/feed'

# Periodically check for new posts from an RSS feed
class Feed
  include Cinch::Plugin

  timer(::Hink.config[:feed][:interval].to_i * 60, method: :check_news)
  @last_update = {}

  def check_news
    bot.loggers.debug('checking news')

    news = Hink.config[:feed][:uris].map { |uri| check_news_site(uri) }
    news.flatten.each do |item|
      bot.channels.uniq.map { |c| c.send(item) }
    end
  end

  private

  def check_news_site(uri)
    @@last_update[uri] ||= Time.now.utc
    extract_items(uri).map { |item| render(item) }.compact
  end

  def extract_items(uri)
    items = parse_feed(uri).items.select { |i| i.date.utc > @@last_update[uri] }
    @@last_update[uri] = items.first.date.utc if items.any?
    items
  end

  def parse_feed(uri)
    RSS::Parser.parse(Mechanize.new.get(uri).body)
  end

  def render(item)
    Formatters::Feed.new(item.to_s, Hink.config[:feed][:template]).render
  end
end
