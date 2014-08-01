require "spec_helper"
require "liquid"
require "formatters/twitter"
require "plugins/tweet"

describe Tweet do
  tweet =  [{
    :id=>1000,
    :text =>"Test tweet! #YOLO",
    :user => {
      :id=>100,
      :name=>"Tester",
      :screen_name=>"the_tester"
    }
  }]
  account_name = "the_tester"
  parsed_tweet = "[Twitter] @the_tester: Test tweet! #YOLO"  
  bot = Cinch::Bot.new
  subject { Tweet.new(bot) }

  before(:all) {
    bot.loggers.level = :fatal
  }

  before(:each) do
    stub_request(:post, "https://api.twitter.com/oauth2/token").to_return({body: ""})
    stub_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=the_tester").to_return({body: tweet})
    stub_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=the_tester&since_id=1001").to_return({body: tweet})
  end


  describe "interval" do
    before(:each) do
      allow(Hink).to receive_messages(config: {
        twitter: {
          accounts: [ account_name ],
          interval: 1,
          template: "[{{ type }}] @{{ user }}: {{ tweet }}"
        }
      })
      allow_any_instance_of(Twitter::REST::Client).
      to receive(:user_timeline) do |block, account, options|
        if options.key?(:since_id)
          if options[:since_id] <= tweet.first[:id]
            tweet
          else
            []
          end
        else
          tweet
        end
      end
      Tweet.class_variable_set(:@@last_update, {})
    end

    context "first run" do
      it "gets the last read id updated" do
        subject.check_tweets
        last_update = subject.class.class_variable_get(:@@last_update)
        expect(last_update[account_name]).to eq(tweet.first[:id])
      end
    end

    context "a new tweet has been posted" do
      before(:each) do
        Tweet.instance_variable_set(:@last_update, {account_name => 99})
      end

      it "tries to parse the tweet" do
        allow_any_instance_of(Formatters::Twitter).
          to receive(:extract_hash_info!)
        subject.check_tweets
      end

      it "renders correct output" do
        allow_any_instance_of(Formatters::Twitter).
          to receive_messages(extract_hash_info!: nil,
                              to_s: parsed_tweet)
        # Formatters::Twitter.any_instance.should_receive(:extract_hash_info!)
        # Formatters::Twitter.any_instance.should_receive(:to_s).and_return(parsed_tweet)
        expect(subject.check_tweets).to eq([parsed_tweet])
      end

    end

    context "no new tweets" do
      it "returns nothing" do
        Tweet.class_variable_set(:@@last_update, {account_name => 1001})
        expect(subject.check_tweets).to eq([])
      end
    end
  end
end
