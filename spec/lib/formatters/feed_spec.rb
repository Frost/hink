require 'spec_helper'
require 'liquid'
require 'formatters/feed'

describe Formatters::Feed do
  let(:feed_url) { 'http://news.example.com/rss' }
  let(:post_url) { 'http://news.example.com/posts/4711' }
  let(:post_title) { 'News post' }
  let(:author) { 'Embraquel D. Tuta' }
  let(:template) { '[{{ type }}] {{ title }} | {{ link }}' }
  let(:output_format) { "[News] #{post_title} | #{post_url}" }
  let(:item) do
    %(
      <item>
        <title>#{post_title}</title>
        <link>#{post_url}</link>
        <description>
          &lt;p&gt;Lorem ipsum dolor sit amet&lt;/p&gt;
          &lt;p&gt;Foo bar baz&lt;/p&gt;
        </description>
        <author>#{author}</author>
        <pubDate>{{date}}</pubDate>
        <guid>#{post_url}</guid>
      </item>
    )
  end

  subject { Formatters::Feed.new(item, template) }

  context 'initialize' do
    it 'sets the @item attribute' do
      feed = Formatters::Feed.new(item, template)
      expect(feed.item).to eq(item)
    end

    it 'extracts the title from the item' do
      formatter = subject
      expect(formatter.title).to eq(post_title)
    end

    it 'extracts the url from the item' do
      formatter = subject
      expect(formatter.link).to eq(post_url)
    end
  end

  context 'to_s' do
    it 'properly formats the string' do
      formatter = subject
      expect(formatter.to_s).to eq(output_format)
    end
  end
end
