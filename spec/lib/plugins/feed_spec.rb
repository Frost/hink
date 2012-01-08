require 'spec_helper'
require 'liquid'

require "formatters/feed"
require 'plugins/feed'

describe Feed do
  let(:feed_url) { "http://news.example.com" }
  let(:feed_template) {
    %(
      <rss version="2.0">
        <channel>
          <title>News feed</title>
          <link>http://news.example.com</link>
          <description>All news</description>
          <item>
            <title>News post</title>
            <link>http://news.example.com/posts/4711</link>
            <description>&lt;p&gt;Lorem ipsum dolor sit amet&lt;/p&gt;&lt;p&gt;Foo bar baz&lt;/p&gt;</description>
            <author>Embraquel D. Tuta</author>
            <pubDate>{{date}}</pubDate>
            <guid>http://news.example.com/posts/4711</guid>
          </item>
        </channel>
      </rss>
    )
  }

  let(:item_output) { "[News] News post | http://news.example.com/posts/4711" }

  subject do
    Feed.new
  end

  before(:all) do
    Formatters::Feed.stub(:initialize)
    Formatters::Feed.stub(:parse_response!)
    Formatters::Feed.stub(:to_s)
  end
  
  describe "interval" do
    before(:each) do
      Hink.stub(:config).and_return(
        {
          feed: {
            uri: "http://news.example.com",
            interval: 5,
            template: "[{{ type }}] {{ title }} | {{ link }}"
          }
        }
      )
    end

    context "a new post exists" do
      before(:each) do
        date = Time.now - 3600
        feed = Liquid::Template.parse(feed_template).render('date' => date.strftime("%a, %d %b %Y %H:%M:%S UTC"))
        stub_request(:get, "http://news.example.com").to_return(
          status: 200,
          body: feed
        )
      end

      it "tries to parse that post" do
        Formatters::Feed.any_instance.should_receive(:'parse_response!')
        Feed.check_news(feed_url)
      end

      it "renders correct output" do
        Formatters::Feed.any_instance.should_receive(:'parse_response!')
        Formatters::Feed.any_instance.should_receive(:to_s).and_return(item_output)
        Feed.check_news(feed_url).should == [item_output]
      end

    end

    context "no new posts" do
      before(:each) do
        date = Time.now - 10*60 - 3600
        feed = Liquid::Template.parse(feed_template).render('date' => date.strftime("%a, %d %b %Y %H:%M:%S GMT+1"))
        stub_request(:get, "http://news.example.com").to_return(
          status: 200,
          body: feed
        )
      end

      it "returns nothing" do
        Feed.check_news(feed_url).should == []
      end
    end
  end
end

