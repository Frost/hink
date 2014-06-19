# coding: utf-8
require 'cinch'
require 'json'
require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'liquid'
require 'helpers/uri'
require "grabber_helpers"

class UrlGrabber
  include Cinch::Plugin

  set(prefix: '', react_on: :channel)
  match(/https?/, :method => :execute)

  def execute(m)
    # don't reply to urls posted by self
    return if m.user.nick == Hink.config[:cinch][:nick]

    # remove all non-printable characters
    message = m.message.scan(/[[:print:]]/).join

    grab_urls(message).each { |response| m.reply(response, true) }
  end

  def grab_urls(m)
    bot.loggers.debug("received url(s): #{message}")

    extract_urls(message).each do |url|
      title = extract_title(bot.loggers,url)

      if title
        template.render({
          url: bitlyfy(url),
          nick: m.user.nick,
          content: title
        })
      end
    end
  end

 private

  def template
    Liquid::Template.parse(Hink.config[:url_grabber][:output_format])
  end

  def extract_urls(message)
    return URI.extract(message, /https?/)
  end

  def extract_title(logger, url)
    logger.debug("extracting title for #{url}")
    uri = Helpers::Uri.new(url)
    if uri.valid?
      return uri.render!
    end
  end

  def bitlyfy(url)
    return nil unless Hink.config[:bitly]
    response = Mechanize.new.get("http://api.bitly.com/v3/shorten",
      :login => Hink.config[:bitly][:login],
      :apiKey => Hink.config[:bitly][:api_key],
      :format => "json",
      :longUrl => url).body
    response_json = JSON.parse(response)

    if response_json["status_code"].to_i == 200
      return response_json["data"]["url"]
    else
      return :error
    end
  rescue => e
    puts e.class, e.message
    return :error
  end
end
