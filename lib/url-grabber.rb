require 'cinch'
require 'json'
require 'open-uri'
require 'nokogiri'
require 'htmlentities'
require 'mechanize'

class UrlGrabber
  include Cinch::Plugin

  prefix ''
  match /https?/, :method => :execute
  react_on :channel

  def execute(m)
    # don't reply to urls posted by self
    return if m.user.nick == $config[:cinch][:nick]

    # remove all non-printable characters
    m.message = m.message.scan(/[[:print:]]/).join

    bot.logger.debug("received url(s): #{m.message}")
    file_output = {}
    extract_urls(m.message).each do |url|
      title,status = UrlGrabber.extract_title(bot.logger, url)
      short_url = bitlyfy(url) unless status == :error
      url_to_use = short_url == :error ? url : short_url
      file_output[url_to_use] = title
      m.reply("#{title} | #{url_to_use} // #{m.user.nick}") if status == :ok
    end
    output_file = $config[:url_grabber][:url_dir] + "/" + m.channel.name.gsub(/^#/,'') + ".html"
    write_output_to_file(output_file, file_output)
  end

  def extract_urls(message)
    return URI.extract(message, /https?/)
  end

  def self.sanitize_title(title)
    HTMLEntities.new.decode(title).gsub(/\s+/, ' ').strip
  end

  def self.extract_title(logger, url)
    logger.debug("extracting title for #{url}")
    agent = Mechanize.new
    begin
      headers = agent.head(url)
      logger.debug(headers.content_type)
      return nil, :not_html unless headers.content_type =~ %r{text/html}
    
      title = Nokogiri::HTML(agent.get(url).body).at_css("title").content
      return nil, :no_title if title.nil?

      title = UrlGrabber.sanitize_title(title)
      
      logger.debug("found #{title}")
      return title, :ok

    rescue Mechanize::ResponseCodeError => e
      ending_crap = /['\)\",.\/]$/

      if e.response_code.to_i == 404 && url =~ ending_crap
        url = url.gsub(ending_crap, '')
        retry
      else
        return e.to_s, :broken
      end
    rescue => e
      puts e.class, e.message, e.backtrace
      return nil, :error
    end
  end

  def bitlyfy(url)
    agent = Mechanize.new
    response_json = JSON.parse(agent.get("http://api.bitly.com/v3/shorten",
      :login => $config[:bitly][:login],
      :apiKey => $config[:bitly][:api_key],
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

  def write_output_to_file(file, urls = {})
    bot.logger.debug("writing to #{file}")
    File.open(file, 'a') do |f|
      urls.each do |url, title|
        f.write(%(#{Time.now}: <a href="#{url}">#{title} - #{url}</a>\n))
      end
    end
  end
end
