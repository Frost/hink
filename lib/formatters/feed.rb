require "mechanize"
require "liquid"
require "rss"
require "htmlentities"
require_relative 'base.rb'

module Formatters
  class Feed
    attr_reader :item, :title, :link, :template

    def initialize(item, template)
      @item = item
      @template = template
      parse_response!
    end

    def to_s
      Liquid::Template.parse(template).render('type' => "News", 'title' => @title, 'link' => @link)
    end

    def render
      parse_response!
      to_s
    end

    private

    def parse_response!
      @doc = Nokogiri::XML(@item)
      coder = HTMLEntities.new
      @title = coder.decode(@doc.css('title').first.inner_html)
      @link = @doc.css('link').first.inner_html
    end
  end
end
