require 'spec_helper'
require 'liquid'
require 'formatters/feed'

describe Formatters::Feed do
  let(:feed_url) { "http://news.example.com/rss" }
  let(:post_url) { "http://news.example.com/posts/4711"}
  let(:post_title) { "News post" }
  let(:author) { "Embraquel D. Tuta" }
  let(:template) { "[{{ type }}] {{ title }} | {{ link }}" }
  let(:output_format) { "[News] #{post_title} | #{post_url}"}
  let(:item) {
    %(
      <item>
        <title>#{post_title}</title>
        <link>#{post_url}</link>
        <description>&lt;p&gt;Lorem ipsum dolor sit amet&lt;/p&gt;&lt;p&gt;Foo bar baz&lt;/p&gt;</description>
        <author>#{author}</author>
        <pubDate>{{date}}</pubDate>
        <guid>#{post_url}</guid>
      </item>
    ) 
  }

  subject { Formatters::Feed.new(item, template) }

  context "initialize" do
    it "sets the @uri attribute" do
      subject.item.should == item
    end
  end

  context "parse" do
    it "extracts the title from the item" do
      formatter = subject
      formatter.parse_response!
      formatter.title.should == post_title
    end

    it "extracts the author from the item" do
      formatter = subject
      formatter.parse_response!
      formatter.author.should == author
    end
    
    it "extracts the url from the item" do
      formatter = subject
      formatter.parse_response!
      formatter.link.should == post_url
    end
  end

  context "to_s" do
    it "properly formats the string" do
      formatter = subject
      formatter.parse_response!
      formatter.to_s.should == output_format
    end
  end
end

