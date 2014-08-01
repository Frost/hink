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
        expect(subject.uri).to eq(uri)
      end
    end

    context "request" do
      it "stores the response" do
        formatter = subject
        formatter.perform_request!
        expect(formatter.response).to eq(response)
      end
    end

    context "parse" do
      it "extracts the title from the response" do
        formatter = subject
        formatter.perform_request!
        formatter.parse_response!
        expect(formatter.title).to eq(title)
      end
    end

    context "to_s" do
      it "properly formats the string" do
        formatter = subject
        formatter.perform_request!
        formatter.parse_response!
        expect(formatter.to_s).to eq(output_format)
      end
    end
  end
end
