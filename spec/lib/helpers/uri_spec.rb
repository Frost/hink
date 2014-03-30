require "spec_helper"
require "helpers/uri"

include WebMock::API

describe Helpers::UriExtractor do
  describe "initialize" do
    it "sets the uri attribute"
  end

  describe "valid?" do
    it "returns true for a valid url" do
      stub_request(:head, "http://validtopdomain.com/existing").to_return(
        status: 200,
        body: ""
      )

      uri = Helpers::Uri.new("http://validtopdomain.com/existing")
      uri.valid?.should == true
    end

    it "returns true for a valid url with some crap at the end" do
      stub_request(:head, "http://validtopdomain.com/existing/)").to_return(
        status: 200,
        body: ""
      )

      uri = Helpers::Uri.new("http://validtopdomain.com/existing/)")
      uri.valid?.should == true
    end

    it "returns false for a non-existing page" do
      stub_request(:head, "http://validtopdomain.com/nonexisting").to_return(
        status: 404,
        body: ""
      )
      uri = Helpers::Uri.new("http://validtopdomain.com/nonexisting")
      uri.valid?.should == false
    end

    it "returns false for a non-existing site" do
      stub_request(:head, "http://invalidtopdomain.com").to_raise(SocketError)

      uri = Helpers::Uri.new("http://invalidtopdomain.com")
      uri.valid?.should == false
    end
  end

  describe "sanitize_ending!" do
    it %(removes '\)",./ from the end of urls) do
      uris = %w[http://ceri.se/) http://ceri.se/, http://ceri.se/.]

      uris.each do |uri|
        uri = Helpers::Uri.new(uri)
        uri.sanitize_ending!
        uri.uri.should == "http://ceri.se/"
      end
    end
  end

  describe "format" do
    it "renders tweets with the Twitter formatter" do
      uri = Helpers::Uri.new("https://twitter.com/#!/eslinge/status/125580490223783937")
      uri.format.should == :twitter
    end

    it "defaults to the Url formatter" do
      uri = Helpers::Uri.new("http://aosetnhusaontehusnothesnuthosnt.com")
      uri.format.should == :url
    end
  end

  describe "render!" do
    let(:twitter_api_uri) { "http://api.twitter.com/1/statuses/show/125580490223783937.json" }
    let(:twitter_response) { {"in_reply_to_user_id_str"=>nil, "contributors"=>nil, "in_reply_to_status_id"=>nil, "in_reply_to_user_id"=>nil, "geo"=>nil, "user"=>{"statuses_count"=>1856, "profile_use_background_image"=>true, "protected"=>false, "default_profile_image"=>false, "follow_request_sent"=>nil, "following"=>nil, "geo_enabled"=>true, "friends_count"=>91, "profile_text_color"=>"333333", "name"=>"Emmy Slinge", "profile_background_image_url"=>"http://a0.twimg.com/profile_background_images/380496805/Nyan_Cat.png", "is_translator"=>false, "show_all_inline_media"=>false, "utc_offset"=>3600, "profile_link_color"=>"93A644", "description"=>"We're right in the middle of a fucking reptile zoo! And somebody's giving booze to these goddamn things!", "location"=>"", "profile_background_image_url_https"=>"https://si0.twimg.com/profile_background_images/380496805/Nyan_Cat.png", "favourites_count"=>2, "time_zone"=>"Stockholm", "profile_background_color"=>"B2DFDA", "url"=>nil, "contributors_enabled"=>false, "profile_background_tile"=>true, "default_profile"=>false, "lang"=>"en", "verified"=>false, "profile_sidebar_fill_color"=>"ffffff", "profile_image_url_https"=>"https://si0.twimg.com/profile_images/1652977972/21790_1242148775_normal.jpg", "listed_count"=>7, "created_at"=>"Fri Mar 13 00:36:42 +0000 2009", "profile_sidebar_border_color"=>"eeeeee", "id"=>24085068, "id_str"=>"24085068", "notifications"=>nil, "followers_count"=>137, "profile_image_url"=>"http://a2.twimg.com/profile_images/1652977972/21790_1242148775_normal.jpg", "screen_name"=>"eslinge"}, "truncated"=>false, "favorited"=>false, "place"=>nil, "retweet_count"=>0, "in_reply_to_screen_name"=>nil, "source"=>"<a href=\"http://www.tweetdeck.com\" rel=\"nofollow\">TweetDeck</a>", "in_reply_to_status_id_str"=>nil, "id"=>125580490223783937, "created_at"=>"Sun Oct 16 14:34:56 +0000 2011", "id_str"=>"125580490223783937", "coordinates"=>nil, "retweeted"=>false, "text"=>"Vidi Vici Veni - I saw, I conquered, I came."} }
    let(:twitter_output) { "[Twitter] @eslinge: Vidi Vici Veni - I saw, I conquered, I came." }

    it "renders tweets with the Twitter formatter" do
      stub_request(:get, twitter_api_uri).to_return(
        status: 200,
        body: twitter_response.to_json
      )

      uri = Helpers::Uri.new("https://twitter.com/#!/eslinge/status/125580490223783937")
      uri.render!.should == twitter_output
    end
  end
end
