require 'spec_helper'
require 'grabber_helpers'

class HelpersTestClass
  include GrabberHelpers
end

describe GrabberHelpers do
  let(:subject) { HelpersTestClass.new }

  describe "constantize" do
    it "transforms the given string to a constant" do
      subject.constantize("Object").should == Object
    end
  end

  describe "underscore" do
    it "replaces spaces with underscores" do
      subject.underscore("foo bar baz").should == "foo_bar_baz"
    end

    it "transforms FooBar to foo_bar" do
      subject.underscore("FooBar").should == "foo_bar"
    end
  end

  describe "sanitize_title" do
    describe "sanitize_title" do
      it "should not mess with sane titles" do
        subject.sanitize_title("").should == ""
        subject.sanitize_title("ab").should == "ab"
      end

      it "should handle linebreaks" do
        subject.sanitize_title("a\nb").should == "a b"
        subject.sanitize_title(" a\nb ").should == "a b"
        subject.sanitize_title(" a\n\n\nb ").should == "a b"
        subject.sanitize_title("\nab\n").should == "ab"
        subject.sanitize_title("\n\n\nab\n\n\n").should == "ab"
      end

      it "should handle whitespace" do
        subject.sanitize_title("a b").should == "a b"
        subject.sanitize_title(" a b ").should == "a b"
        subject.sanitize_title("   a   b   ").should == "a b"
      end
    end
  end
end
