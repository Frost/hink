# coding: utf-8
require "cinch"
require "json"
require "mechanize"
require "liquid"

module Formatters
  class Twitter < Base
    attr_reader :tweet_id, :user, :tweet_text
    FORMAT = %r{^https?://(?:www\.)?twitter.com/(?:#!/)?([A-Za-z0-9_]+)/status/(\d+)}

    def initialize(uri, template = "")
      super
      @user, @tweet_id = extract_info
    end

    def extract_info
      if @uri =~ FORMAT
        return $1, $2
      end
    end

    def perform_request!
      agent = Mechanize.new
      response = agent.get("http://api.twitter.com/1/statuses/show/#{@tweet_id}.json")
      @response = JSON.load(response.body)
    end

    def parse_response!
      @tweet_text = response['text']
    end

    def to_s
      Liquid::Template.parse(@template).render('type' => "Twitter", 'user' => @user, 'tweet' => @tweet_text)
    end

  end
end
