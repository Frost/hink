require 'spec_helper'
require 'plugins/wiki_lookup'
require 'ostruct'

describe WikiLookup do
  let(:bot) { Cinch::Bot.new }
  before(:all) do
    bot.loggers.level = :fatal
    Hink.setup(bot)
  end

  describe "LINK_REGEX" do
    it "catches simple links" do
      result = "[[simple]]".scan(WikiLookup::LINK_REGEX)

      matches = result.map(&:first)

      matches.should == ["simple"]
    end

    it "catches links with multiple words" do
      result = "[[one two three]]".scan(WikiLookup::LINK_REGEX)

      matches = result.map(&:first)

      matches.should == ["one two three"]
    end

    it "catches a line with double links" do
      result = "[[one]] and [[two]]".scan(WikiLookup::LINK_REGEX)

      matches = result.map(&:first)

      matches.should == ["one", "two"]
    end
  end

  describe "extract_urls" do
    subject { WikiLookup.new(bot) }
    let(:message) { OpenStruct.new }

    it "returns the url for the wiki page if it exists" do
      stub_request(:get, "#{Hink.config[:wiki_lookup][:url]}foobar").to_return(
        status: 200,
        body: "<html><head><title>Foobar</title></head></html>"
      )

      message.message = "[[Foobar]]"

      result = subject.extract_urls(message)
      result.should == {
        "Foobar" => "#{Hink.config[:wiki_lookup][:url]}foobar"
      }

    end

    it "can extract multiple urls" do
      stub_request(:get, "#{Hink.config[:wiki_lookup][:url]}foo").to_return(
        status: 200,
        body: "<html><head><title>Foo</title></head></html>"
      )
      stub_request(:get, "#{Hink.config[:wiki_lookup][:url]}bar").to_return(
        status: 200,
        body: "<html><head><title>Bar</title></head></html>"
      )

      message.message = "[[Foo]] [[Bar]]"

      result = subject.extract_urls(message)
      result.should == {
        "Foo" => "#{Hink.config[:wiki_lookup][:url]}foo",
        "Bar" => "#{Hink.config[:wiki_lookup][:url]}bar"
      }
    end

    it "doesn't return anything for non-existing pages" do
      stub_request(:get, "#{Hink.config[:wiki_lookup][:url]}foo").to_return(
        status: 200,
        body: "<html><head><title>Search results for foo</title></head></html>"
      )

      message.message = "[[Foo]]"
      result = subject.extract_urls(message)
      result.should == {}
    end

    it "returns nothing if a request fails" do
      stub_request(:get, "#{Hink.config[:wiki_lookup][:url]}foo").to_return(
        status: 404,
        body: "<html><head><title>Search results for foo</title></head></html>"
      )
      message.message = "[[Foo]]"
      result = subject.extract_urls(message)
      result.should == {}
    end
  end
end
