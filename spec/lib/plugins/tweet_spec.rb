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
  subject { Tweet.new }

  describe "interval" do
    before(:each) do
      Hink.stub(:config).and_return(
        {
          twitter: {
            account: "Tester",
            interval: 1,
            template: "[{{ type }}] @{{ user }}: {{ tweet }}"
          }
        }
      )
      Twitter.stub(:user_timeline) do |account, arg|
        if arg
          if arg[:since_id] <= tweet.first[:id]
            tweet
          else
            []
          end
        else
          tweet
        end
      end
      Tweet.instance_variable_set(:@last_update, {})
    end

    context "first run" do
      it "gets the last read id updated" do
        Tweet.check_tweets(account_name)
        last_update = Tweet.instance_variable_get(:@last_update)
        last_update[account_name].should == tweet.first[:id]
      end
    end

    context "a new tweet has been posted" do
      before(:each) do
        Tweet.instance_variable_set(:@last_update, {account_name => 99})
      end
      
      it "tries to parse the tweet" do
        Formatters::Twitter.any_instance.should_receive(:extract_hash_info!)
        Tweet.check_tweets(account_name)
      end
      
      it "renders correct output" do
        Formatters::Twitter.any_instance.should_receive(:extract_hash_info!)
        Formatters::Twitter.any_instance.should_receive(:to_s).and_return(parsed_tweet)
        Tweet.check_tweets(account_name).should == [parsed_tweet]
      end

    end

    context "no new tweets" do
      it "returns nothing" do
        Tweet.instance_variable_set(:@last_update, {account_name => 1001})
        Tweet.check_tweets(account_name).should == []
      end
    end
  end
end
