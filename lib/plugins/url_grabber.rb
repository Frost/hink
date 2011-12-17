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

  prefix ''
  match /https?/, :method => :execute
  react_on :channel

  def execute(m)
    # don't reply to urls posted by self
    if m.user.nick == Hink.config[:cinch][:nick]
      return 
    end

    # remove all non-printable characters
    message = m.message.scan(/[[:print:]]/).join

    bot.logger.debug("received url(s): #{message}")
    file_output = {}
    extract_urls(message).each do |url|
      title = self.class.extract_title(bot.logger,url)

      if title
        short_url = bitlyfy(url)
        file_output[{:url => url, :bitly => short_url}] = title
        output = Liquid::Template.parse(Hink.config[:url_grabber][:output_format])
        m.reply(output.render('url' => short_url, 'nick' => m.user.nick, 'content' => title))
      end

    end
    output_file = Hink.config[:url_grabber][:url_dir] + "/" + m.channel.name.gsub(/^#/,'') + ".html"
    write_output_to_file(output_file, file_output, m.channel.name)
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
    response_json = JSON.parse(agent.get("http://api.bitly.com/v3/shorten",
      :login => Hink.config[:bitly][:login],
      :apiKey => Hink.config[:bitly][:api_key],
      :format => "json",
      :longUrl => url).body)

    bot.logger.debug(response_json)
    
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

  def write_output_to_file(file, urls = {}, channel = '?')
    bot.logger.debug("writing to #{file}")
	html = HTMLEntities.new
    File.open(file, 'a') do |f|
	  if f.size == 0
	    f << %{
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8"/>
    <title>#{channel} - Länksamling</title>
    <style>
      a:hover {color: red;}
    </style>
  </head>
<body>
  <pre>
}
	  end
      urls.each do |url, title|
        f.write(%(#{Time.now}: <a href="#{url[:url]}">#{html.encode title}</a>#{url[:bitly].nil? ? '' : %{<a href="#{url[:bitly]}">#{url[:bitly]}</a>}}\n))
      end
    end
  end

end
