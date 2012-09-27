require 'spec_helper'
require 'plugins/wiki_lookup'

describe WikiLookup do
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
end
