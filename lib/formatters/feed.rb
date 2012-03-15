require "mechanize"
require "liquid"
require "rss"
require "htmlentities"

module Formatters
  class Feed
    attr_reader :item, :title, :author, :link, :template

    def initialize(item, template)
      @item = item
      @template = template
    end

    def parse_response!
      @item = Nokogiri::XML(@item)
      coder = HTMLEntities.new
      @title = coder.decode(@item.css('title').first.inner_html)
      @author = coder.decode(@item.css('author').first.inner_html)
      @link = @item.css('link').first.inner_html
    end

    def to_s
      Liquid::Template.parse(template).render('type' => "News", 'title' => @title, 'link' => @link)
    end
  end
end
