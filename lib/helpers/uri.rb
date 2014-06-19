require "config"
require "grabber_helpers"
require "mechanize"
require "formatters/twitter"
require "formatters/url"

module Helpers
  class Uri
    include GrabberHelpers
    attr_reader :uri

    def initialize(uri)
      @uri = uri
      @agent = Mechanize.new
    end

    def valid?
      begin
        @headers = @agent.head(@uri)
        true
      rescue Mechanize::ResponseCodeError => e
        if e.response_code.to_i == 404 && sanitize_ending!
          retry
        else
          false
        end
      rescue SocketError => e
        false
      end
    end

    # Returns true if anything was sanitized,
    # otherwise false.
    def sanitize_ending!
      ending_crap = /['\)\",.\/]$/

      if @uri =~ ending_crap
        uri.gsub!(ending_crap, '')
        true
      else
        false
      end
    end

    def format
      case @uri
      when Formatters::Twitter::FORMAT
        :twitter
      else
        :url
      end
    end

    def formatter
      case format
      when :twitter
        Formatters::Twitter
      else
        Formatters::Url
      end
    end

    def render!
      formatter.parse(@uri, Hink.config[:url_grabber][:formatters][format])
    end
  end

  class UriExtractor

    def self.valid?(uri)
      Uri.new(uri).valid?
    end

  end
end
