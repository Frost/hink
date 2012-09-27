require 'cinch'
require 'mechanize'

class WikiLookup
  include Cinch::Plugin

  LINK_REGEX = /\[\[([^\]]+)\]\]/

  set(prefix: '')
  match LINK_REGEX, :react_on => :channel

  def execute(m, term)
    result = self.class.extract_urls(m)
    result.map do |match, title|
      m.reply("[[#{match}]]: #{title}")
    end
  end

  def self.extract_urls(message)
    matches = message.message.scan(LINK_REGEX)

    result = {}

    matches.flatten.map do |match|
      begin
        url = "#{Hink.config[:wiki_lookup][:url]}#{underscore match}"
        agent = Mechanize.new
        page = agent.get(url)
        page_title = Nokogiri::HTML(page.body).at_css('title').content

        if page_title !~ /^Search results for .*/
          result[match] = url
        end
      rescue Mechanize::ResponseCodeError => e
        puts e.inspect
      end
    end

    return result
  end

end
