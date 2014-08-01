require 'spec_helper'
require 'grabber_helpers'

class HelpersTestClass
  include GrabberHelpers
end

describe GrabberHelpers do
  let(:subject) { HelpersTestClass.new }

  describe "constantize" do
    it "transforms the given string to a constant" do
      expect(subject.constantize("Object")).to eq(Object)
    end
  end

  describe "underscore" do
    it "replaces spaces with underscores" do
      expect(subject.underscore("foo bar baz")).to eq("foo_bar_baz")
    end

    it "transforms FooBar to foo_bar" do
      expect(subject.underscore("FooBar")).to eq("foo_bar")
    end
  end

  describe "sanitize_title" do
    describe "sanitize_title" do
      it "should not mess with sane titles" do
        expect(subject.sanitize_title("")).to eq("")
        expect(subject.sanitize_title("ab")).to eq("ab")
      end

      it "should handle linebreaks" do
        expect(subject.sanitize_title("a\nb")).to eq("a b")
        expect(subject.sanitize_title(" a\nb ")).to eq("a b")
        expect(subject.sanitize_title(" a\n\n\nb ")).to eq("a b")
        expect(subject.sanitize_title("\nab\n")).to eq("ab")
        expect(subject.sanitize_title("\n\n\nab\n\n\n")).to eq("ab")
      end

      it "should handle whitespace" do
        expect(subject.sanitize_title("a b")).to eq("a b")
        expect(subject.sanitize_title(" a b ")).to eq("a b")
        expect(subject.sanitize_title("   a   b   ")).to eq("a b")
      end
    end
  end
end
