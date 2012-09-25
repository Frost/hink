require 'cinch'
require 'mechanize'

class WikiLookup
  include Cinch::Plugin

  set(prefix: '')
  match /\[\[(.*)\]\]/, :react_on => :channel

  def execute(m, term)
    url = "#{Hink.config[:wiki_lookup][:url]}#{underscore term}"
    agent = Mechanize.new
    page = agent.get(url)
    page_title = Nokogiri::HTML(page.body).at_css('title').content
    
    if page_title !~ /^Search results for .*/
      m.reply("[[#{term}]]: #{url}")
    end
  end
end
