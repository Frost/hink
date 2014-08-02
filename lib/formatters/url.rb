require 'mechanize'
require 'liquid'
require 'nokogiri'
require 'htmlentities'
require_relative 'base.rb'

module Formatters
  # Format an url with its title
  class Url < Base
    attr_reader :title

    def perform_request!
      agent = Mechanize.new
      response = agent.get(@uri)
      @response = response.body
    end

    def parse_response!
      html = Nokogiri::HTML(@response).at_css('title').content || ''

      @title = sanitize(html)
    end

    def sanitize(title)
      HTMLEntities.new.decode(title).gsub(/\s+/, ' ').strip
    end

    def to_s
      Liquid::Template.parse(template).render('type' => 'Url', 'title' => @title)
    end
  end
end
