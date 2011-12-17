require 'spec_helper'
require "formatters/url"

describe Formatters::Url do
  describe "valid url" do
    let(:uri) { "http://ceri.se" }
    let(:title) { "ceri.se" }
    let(:response) { "<html><head><title>#{title}</title></head></html>" }
    let(:template) { "[{{ type }}] {{ title }}" }
    let(:output_format) { "[Url] ceri.se" }
    subject { Formatters::Url.new(uri, template) }

    before(:each) do
      stub_request(:get, "http://ceri.se").to_return(
        status: 200,
        body: response
      )
    end

    context "initialize" do
      it "sets the @uri attribute" do
        subject.uri.should == uri
      end
    end

    context "request" do
      it "stores the response" do
        formatter = subject
        formatter.perform_request!
        formatter.response.should == response
      end
    end

    context "parse" do
      it "extracts the title from the response" do
        formatter = subject
        formatter.perform_request!
        formatter.parse_response!
        formatter.title.should == title
      end
    end

    context "to_s" do
      it "properly formats the string" do
        formatter = subject
        formatter.perform_request!
        formatter.parse_response!
        formatter.to_s.should == output_format
      end
    end
  end
end
