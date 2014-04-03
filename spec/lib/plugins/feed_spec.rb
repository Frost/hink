require 'spec_helper'
require 'liquid'

require "formatters/feed"
require 'plugins/feed'

describe Feed do
  let(:bot) { Cinch::Bot.new }
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

  subject { Feed.new(bot) }

  before(:all) do
    bot.loggers.level = :fatal
    Hink.setup(bot)
    Formatters::Feed.stub(:to_s)
  end

  describe "interval" do
    before(:each) do
      Hink.stub(:config).and_return(
        {
          feed: {
            uris: %w[ http://news.example.com ],
            interval: 5,
            template: "[{{ type }}] {{ title }} | {{ link }}"
          }
        }
      )
      Feed.class_variable_set(:@@last_update, {})
    end


    context "a new post exists" do
      before(:each) do
        date = Time.now + 3600
        feed = Liquid::Template.parse(feed_template).render(
          'date' => date.strftime("%a, %d %b %Y %H:%M:%S UTC"))
        stub_request(:get, feed_url).to_return(
          status: 200,
          body: feed
        )
      end

      it "tries to parse that post" do
        Formatters::Feed.any_instance.should_receive(:render)
        subject.check_news
      end

      it "renders correct output" do
        Formatters::Feed.any_instance.should_receive(:render).and_return(item_output)
        subject.check_news.should == [item_output]
      end

    end

    context "no new posts" do
      before(:each) do
        date = Time.now.utc - 3600
        feed = Liquid::Template.parse(feed_template).render('date' => date.strftime("%a, %d %b %Y %H:%M:%S GMT+1"))
        stub_request(:get, feed_url).to_return(
          status: 200,
          body: feed
        )
      end

      it "returns nothing" do
        subject.check_news.should == []
      end
    end
  end
end

