require 'spec_helper'
require 'plugins/url_grabber'

describe UrlGrabber do
  let(:bot) { Cinch::Bot.new }
  let(:subject) { UrlGrabber.new(bot) }
  let(:url) { "http://example.com" }
  let(:html_response) {
    %(
    <html>
      <head>
        <title>Page title</title>
      </head>
      <body>
        <p>Herp derp</p>
      </body>
    </html>
    )
  }
  let(:expected_output) { "[Url] Page title | http://bit.ly/short" }

  before(:each) do
    bot.loggers.level = :fatal
    Hink.setup(bot)
  end

  describe "grab_urls" do
    before(:each) do
      stub_request(:get, url).to_return(
        status: 200,
        body: html_response
      )
    end

    it "does nothing on message that doesn't contain any URI"
    it "extracts urls from a message"
  end
end
