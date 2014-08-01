require "spec_helper"
require "formatters/base"

describe Formatters::Base do
  let(:uri) { "http://ceri.se" }
  let(:template) { "" }

  subject { Formatters::Base.new(uri, template) }

  context "initialize" do
    it "sets the @uri attribute" do
      expect(subject.uri).to eq(uri)
    end

    it "sets the @template attribute" do
      expect(subject.template).to eq(template)
    end
  end

  %w[perform_request! parse_response!].each do |method|
    it "should raise NotImplementedError" do
      expect(proc { subject.send(method) }).to raise_error(NotImplementedError)
    end
  end

  context "to_s" do
    it "has an empty string representation" do
      expect(subject.to_s).to eq("")
    end
  end
end
