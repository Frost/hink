require 'spec_helper'
require 'formatters/twitter'

describe Formatters::Twitter do
  describe 'valid tweet' do
    let(:tweet_id) { '125580490223783937' }
    let(:tweet_text) { 'Vidi Vici Veni - I saw, I conquered, I came.' }
    let(:uri) { 'https://twitter.com/#!/eslinge/status/125580490223783937' }
    let(:mobile_uri) { 'https://mobile.twitter.com/#!/eslinge/status/125580490223783937' }
    let(:api_uri) { 'http://api.twitter.com/1/statuses/show/125580490223783937.json' }
    let(:response) { { 'in_reply_to_user_id_str'=>nil, 'contributors'=>nil, 'in_reply_to_status_id'=>nil, 'in_reply_to_user_id'=>nil, 'geo'=>nil, 'user'=>{'statuses_count'=>1856, 'profile_use_background_image'=>true, 'protected'=>false, 'default_profile_image'=>false, 'follow_request_sent'=>nil, 'following'=>nil, 'geo_enabled'=>true, 'friends_count'=>91, 'profile_text_color'=>'333333', 'name'=>'Emmy Slinge', 'profile_background_image_url'=>'http://a0.twimg.com/profile_background_images/380496805/Nyan_Cat.png', 'is_translator'=>false, 'show_all_inline_media'=>false, 'utc_offset'=>3600, 'profile_link_color'=>'93A644', 'description'=>"We're right in the middle of a fucking reptile zoo! And somebody's giving booze to these goddamn things!", 'location'=>'', 'profile_background_image_url_https'=>'https://si0.twimg.com/profile_background_images/380496805/Nyan_Cat.png', 'favourites_count'=>2, 'time_zone'=>'Stockholm', 'profile_background_color'=>'B2DFDA', 'url'=>nil, 'contributors_enabled'=>false, 'profile_background_tile'=>true, 'default_profile'=>false, 'lang'=>'en', 'verified'=>false, 'profile_sidebar_fill_color'=>'ffffff', 'profile_image_url_https'=>'https://si0.twimg.com/profile_images/1652977972/21790_1242148775_normal.jpg', 'listed_count'=>7, 'created_at'=>'Fri Mar 13 00:36:42 +0000 2009', 'profile_sidebar_border_color'=>'eeeeee', 'id'=>24085068, 'id_str'=>'24085068', 'notifications'=>nil, 'followers_count'=>137, 'profile_image_url'=>'http://a2.twimg.com/profile_images/1652977972/21790_1242148775_normal.jpg', 'screen_name'=>'eslinge'}, 'truncated'=>false, 'favorited'=>false, 'place'=>nil, 'retweet_count'=>0, 'in_reply_to_screen_name'=>nil, 'source'=>'<a href=\"http://www.tweetdeck.com\" rel=\"nofollow\">TweetDeck</a>', 'in_reply_to_status_id_str'=>nil, 'id'=>125580490223783937, 'created_at'=>'Sun Oct 16 14:34:56 +0000 2011', 'id_str'=>'125580490223783937', 'coordinates'=>nil, 'retweeted'=>false, 'text'=>'Vidi Vici Veni - I saw, I conquered, I came.' } }
    let(:template) { '[{{type}}] @{{user}}: {{tweet}}' }
    let(:output_format) { "[Twitter] @eslinge: #{tweet_text}" }
    subject { Formatters::Twitter.new(uri, template) }

    before(:each) do
      stub_request(:get, 'http://api.twitter.com/1/statuses/show/125580490223783937.json').to_return(
        status: 200,
        body: response.to_json
      )
    end

    context 'FORMAT' do
      it 'should match twitter.com' do
        expect(Formatters::Twitter::FORMAT).to match(uri)
      end

      it 'should match mobile.twitter.com' do
        expect(Formatters::Twitter::FORMAT).to match(mobile_uri)
      end
    end

    context 'initialize' do
      it 'sets the @uri attribute' do
        expect(subject.uri).to eq(uri)
      end

      it 'extracts the status id' do
        expect(subject.tweet_id).to eq(tweet_id)
      end

      it 'extracts the user name' do
        expect(subject.user).to eq('eslinge')
      end
    end

    context 'request' do
      it 'stores the response' do
        formatter = subject
        formatter.perform_request!
        expect(formatter.response).to eq(response)
      end

    end

    context 'parse' do
      it 'extrats the status text from the response' do
        formatter = subject
        formatter.perform_request!
        formatter.parse_response!
        expect(formatter.tweet_text).to eq(tweet_text)
      end
    end

    context 'to_s' do
      it 'properly formats the string' do
        formatter = subject
        formatter.perform_request!
        formatter.parse_response!
        expect(formatter.to_s).to eq(output_format)
      end
    end
  end
end
