# coding: utf-8
require 'cinch'
require 'json'
require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'liquid'
require 'helpers/uri'
require 'grabber_helpers'

# Fetch html title from a URL, if present
class UrlGrabber
  include Cinch::Plugin

  set(prefix: '', react_on: :channel)
  match(/https?/, method: :execute)

  def execute(m)
    # don't reply to urls posted by self
    return if m.user.nick == Hink.config[:cinch][:nick]

    # remove all non-printable characters
    message = m.message.scan(/[[:print:]]/).join

    grab_urls(message).each do |response|
      m.reply(render(m.user.nick, response[0], response[1]), true)
    end
  end

  def grab_urls(message)
    bot.loggers.debug("received url(s): #{message}")

    extract_urls(message).map do |url|
      title = extract_title(url)
      [url, title] if title
    end
  end

  private

  def template
    Liquid::Template.parse(Hink.config[:url_grabber][:output_format])
  end

  def render(nick, title, url)
    template.render(url: bitlyfy(url),
                    nick: nick,
                    content: title
                   )
  end

  def extract_urls(message)
    URI.extract(message, /https?/)
  end

  def extract_title(url)
    bot.loggers.debug("extracting title for #{url}")
    uri = Helpers::Uri.new(url)
    uri.render! if uri.valid?
  end

  def bitlyfy(url)
    return nil unless Hink.config[:bitly]
    response_json = JSON.parse(bitly_request(url))

    if response_json['status_code'].to_i == 200
      response_json['data']['url']
    else
      :error
    end
  rescue => e
    puts e.class, e.message
    :error
  end

  def bitly_request(url)
    params = {
      login: Hink.config[:bitly][:login],
      apiKey: Hink.config[:bitly][:api_key],
      format: 'json',
      longUrl: url
    }
    Mechanize.new.get('http://api.bitly.com/v3/shorten', params).body
  end
end
