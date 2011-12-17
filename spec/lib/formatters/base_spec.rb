require "spec_helper"
require "formatters/base"

describe Formatters::Base do
  let(:uri) { "http://ceri.se" }
  let(:template) { "" }

  subject { Formatters::Base.new(uri, template) }

  context "initialize" do
    it "sets the @uri attribute" do
      subject.uri.should == uri
    end

    it "sets the @template attribute" do
      subject.template.should == template
    end
  end

  %w[perform_request! parse_response!].each do |method|
    it "should raise NotImplementedError" do
      proc { subject.send(method) }.should raise_error(NotImplementedError)
    end
  end

  context "to_s" do
    it "has an empty string representation" do
      subject.to_s.should == ""
    end
  end
end
