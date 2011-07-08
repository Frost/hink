require 'json'
require 'open-uri'
require 'nokogiri'
require 'htmlentities'

class UrlGrabber
  include  Cinch::Plugin

  match /https?/, :method => :execute
  react_on :channel

  def execute(m)
    bot.logger.info("received url: #{m.message}")
    file_output = {}
    extract_urls(m.message).each do |url|
      title,status = extract_title(url)
      short_url = bitlyfy(url) unless status == :error
      url_to_use = short_url == :error ? url : short_url
      file_output[url_to_use] = title
      m.reply("#{title} | #{url_to_use} // #{m.nick}") if status == :ok
    end
    output_file = $config[:url_grabber][:url_dir] + "/" + m.channel.gsub('^#','')
    write_output_to_file(output_file, file_output)
  end

  def extract_urls(message)
    return URI.extract(message, /https?/)
  end

  def extract_title(url)
    agent = Mechanize.new
    
    begin
      puts url
      headers = agent.head(url)
      return nil, :not_html unless headers =~ %r{text/html}
    
      document = Nokogiri::HTML(agent.get(url).body).at_css("title")
      
      return nil, :no_title if title.nil?
      
      puts title
      return HTMLEntities.decode(title), :ok

    rescue Mechanize::ResponseCodeError => e
      ending_crap = /['\)\",.\/]$/

      if e.response_code.to_i == 404 && url =~ ending_crap
        url = url.gsub(ending_crap, '')
        retry
      else
        return nil, :broken
      end
    rescue => e
      puts e.class, e.message
      return nil, :error
    end
  end

  def bitlyfy(url)
    agent = Mechanize.new
    response_json = JSON.parse(agent.get("http://api.bitly.com",
      :login => $config[:bitly][:login]
      :apiKey => $config[:bitly][:api_key]
      :format => "json",
      :longUrl => url).body)
    
    case response_json["status_code"]
    when 200
      return response_json["url"]
    when 200
      return :error
    end
  rescue => e
    puts e.class, e.message
    return :error
  end

  def write_output_to_file(file, urls = {})
    File.open(file, 'a') do |f|
      urls.each do |url, title|
        f.write(%(#{Time.now}: <a href="#{url}">#{title} - #{url}</a>\n))
      end
    end
  end
end
