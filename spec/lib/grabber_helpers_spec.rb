require 'spec_helper'
require 'grabber_helpers'

describe GrabberHelpers do
  before(:all) do
    class Foo
      include GrabberHelpers
    end
    @subject = Foo.new
  end
  describe "constantize" do
    it "transforms the given string to a constant" do
      @subject.constantize("Object").should == Object
    end
  end

  describe "underscore" do
    it "replaces spaces with underscores" do
      @subject.underscore("foo bar baz").should == "foo_bar_baz"
    end

    it "transforms FooBar to foo_bar" do
      @subject.underscore("FooBar").should == "foo_bar"
    end
  end

  describe "genitive" do
    it "appends 's to words not ending with an s" do
      @subject.genitive("Martin").should == "Martin's"
    end
    it "appends ' to words ending with an s" do
      @subject.genitive("Hans").should == "Hans'"
    end
  end
end
