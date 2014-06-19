require 'cinch'
require 'mechanize'
require 'grabber_helpers'

class WikiLookup
  include Cinch::Plugin
  include GrabberHelpers

  LINK_REGEX = /\[\[([^\]]+)\]\]/

  set(
    prefix: '',
    :react_on => :channel
  )
  match LINK_REGEX

  def execute(m, term)
    result = extract_urls(m)
    result.map do |match, title|
      m.reply("[[#{match}]]: #{title}")
    end
  end

  def extract_urls(message)
    matches = message.message.scan(LINK_REGEX)

    result = {}

    matches.flatten.map do |match|
      if url = extract_url(match)
        result[match] = url
      end
    end

    return result
  end

  def extract_url(match)
    url = url(match)
    page = fetch_page(url)
    return url if page && title(page) !~ /^Search results for .*/
  end

  def fetch_page(url)
    begin
      return Mechanize.new.get(url)
    rescue Mechanize::ResponseCodeError => e
      bot.loggers.debug e.inspect
      return nil
    end
  end

  def url(match)
    Hink.config[:wiki_lookup][:url] + underscore(match)
  end

  def title(page)
    Nokogiri::HTML(page.body).at_css('title').content
  end
end
