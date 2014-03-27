# coding: utf-8
require 'cinch'
require 'json'
require 'open-uri'
require 'nokogiri'
require 'htmlentities'
require 'mechanize'
require 'liquid'
require 'helpers/uri'
require "formatters/url"
require "formatters/twitter"

class UrlGrabber
  include Cinch::Plugin

  set(prefix: '', react_on: :channel)
  match(/https?/, :method => :execute)

  def execute(m)
    # don't reply to urls posted by self
    return if m.user.nick == Hink.config[:cinch][:nick]

    # remove all non-printable characters
    message = m.message.scan(/[[:print:]]/).join

    bot.loggers.debug("received url(s): #{message}")

    extract_urls(message).each do |url|
      title = self.class.extract_title(bot.loggers,url)

      if title
        output = render({url: bitlyfy(url), nick: m.user.nick, content: title})
        m.reply(output)
      end
    end
  end

  def render(locals)
    template = Liquid::Template.parse(Hink.config[:url_grabber][:output_format])
    template.render(locals)
  end

  def extract_urls(message)
    return URI.extract(message, /https?/)
  end

  def self.sanitize_title(title)
    HTMLEntities.new.decode(title).gsub(/\s+/, ' ').strip
  end

  def self.extract_title(logger, url)
    logger.debug("extracting title for #{url}")
    uri = Helpers::Uri.new(url)
    if uri.valid?
      return uri.render!
    end
  end

  def bitlyfy(url)
    return nil unless Hink.config[:bitly]
    agent = Mechanize.new
    response = agent.get("http://api.bitly.com/v3/shorten",
      :login => Hink.config[:bitly][:login],
      :apiKey => Hink.config[:bitly][:api_key],
      :format => "json",
      :longUrl => url).body
    response_json = JSON.parse(response)
    
    case response_json["status_code"]
    when 200
      return response_json["data"]["url"]
    when 200
      return :error
    end
  rescue => e
    puts e.class, e.message
    return :error
  end
end
