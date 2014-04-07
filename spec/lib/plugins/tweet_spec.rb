require "spec_helper"
require "liquid"
require "formatters/twitter"
require "plugins/tweet"

describe Tweet do
  let(:tweet) {
     [{:id=>1000, :text =>"Test tweet! #YOLO", :user => {:id=>100, :name=>"Tester", :screen_name=>"the_tester"}}]
  }
  let(:account_name) { "the_tester" }
  let(:parsed_tweet) { "[Twitter] @the_tester: Test tweet! #YOLO"  }
  let(:bot) { Cinch::Bot.new }
  subject { Tweet.new(bot) }

  before(:all) {
    bot.loggers.level = :fatal
  }

  describe "interval" do
    before(:each) do
      Hink.stub(:config).and_return(
        {
          twitter: {
            accounts: [ account_name ],
            interval: 1,
            template: "[{{ type }}] @{{ user }}: {{ tweet }}"
          }
        }
      )
      Twitter.stub(:user_timeline) do |account, arg|
        if arg && arg[:since_id]
          if arg[:since_id] <= tweet.first[:id]
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
        last_update[account_name].should == tweet.first[:id]
      end
    end

    context "a new tweet has been posted" do
      before(:each) do
        Tweet.instance_variable_set(:@last_update, {account_name => 99})
      end

      it "tries to parse the tweet" do
        Formatters::Twitter.any_instance.should_receive(:extract_hash_info!)
        subject.check_tweets
      end

      it "renders correct output" do
        Formatters::Twitter.any_instance.should_receive(:extract_hash_info!)
        Formatters::Twitter.any_instance.should_receive(:to_s).and_return(parsed_tweet)
        subject.check_tweets.should == [parsed_tweet]
      end

    end

    context "no new tweets" do
      it "returns nothing" do
        Tweet.class_variable_set(:@@last_update, {account_name => 1001})
        subject.check_tweets.should == []
      end
    end
  end
end
