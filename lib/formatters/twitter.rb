# coding: utf-8
require "cinch"
require "json"
require "mechanize"
require "liquid"

module Formatters
  class Twitter
    attr_reader :uri, :response, :tweet_id, :user, :tweet_text

    def initialize(uri, template = "")
      @uri = uri
      @template = template
      @user, @tweet_id = extract_info
    end

    def parse_response!
      @tweet_text = response['text']
    end

    def perform_request!
      agent = Mechanize.new
      response = agent.get("http://api.twitter.com/1/statuses/show/125580490223783937.json")
      @response = JSON.load(response.body)
      
    end

    def extract_info
      tweet_regex = %r{^https?://(?:www\.)?twitter.com/(?:#!/)?([a-z0-9]+)/status/(\d+)}
      if @uri =~ tweet_regex
        return $1, $2
      end
    end

    def to_s
      Liquid::Template.parse(@template).render('type' => "Twitter", 'user' => @user, 'tweet' => @tweet_text)
    end

  end
end
