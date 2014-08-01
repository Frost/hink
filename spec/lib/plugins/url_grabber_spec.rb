require 'spec_helper'
require 'plugins/url_grabber'
require 'ostruct'

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

  describe "execute" do
    before(:each) do
      stub_request(:head, url).to_return(
        status: 200,
        body: html_response
      )
      stub_request(:get, url).to_return(
        status: 200,
        body: html_response
      )
      stub_request(:get, "http://api.bitly.com/v3/shorten?apiKey=your_bitly_api_key_here&format=json&login=your_bitly_login_here&longUrl=%5BUrl%5D%20Page%20title").
      to_return(status: 200, body: {
        status_code: 200,
        data: {
          values: [
            "http://bit.ly/foobar"
          ]
        }
      }.to_json)
    end
    it "replies to the person posting the URL(s)" do
      message = double(user: OpenStruct.new(nick: "Testuser"),
                       message: "http://example.com" )

      allow(message).to receive_messages(reply: /^Testuser/)

      subject.execute(message)
    end

    it "bitlifies the replies"

    it "renders its replies"
  end

  describe "grab_urls" do
    before(:each) do
      stub_request(:head, url).to_return(
        status: 200,
        body: html_response
      )
      stub_request(:get, url).to_return(
        status: 200,
        body: html_response
      )
    end

    it "does nothing on message that doesn't contain any URI" do
      message = "foo bar baz"

      expect(subject.grab_urls(message)).to eq([])
    end

    it "extracts urls from a message" do
      message = "http://example.com"
      expect(subject.grab_urls(message)).to eq([
        ["http://example.com","[Url] Page title"]
      ])
    end

    it "extracts multiple urls from a message" do
      message = "http://example.com http://example.com"
      expect(subject.grab_urls(message)).to eq([
        ["http://example.com","[Url] Page title"],
        ["http://example.com","[Url] Page title"]
      ])
    end

  end
end
