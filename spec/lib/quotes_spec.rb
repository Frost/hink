require "spec_helper"
require 'quotes'
require "ostruct"

def valid_attributes
  {
    added_by: "Frost",
    user: "frost",
    host: "ceri.se",
    channel: "test-hink",
    quote: "<Frost> Some random boring made-up self-quote"
  }
end

def valid_parameters
  m = OpenStruct.new(
    user: OpenStruct.new(
      nick: "Frost",
      user: "frost",
      host: "ceri.se"
    ),
    channel: "hink-test"
  )
  return m, "<Frost> Some random boring made-up self-quote"
end

describe Quote do

  describe "creation" do
    context "with valid attributes" do
      it "can be saved" do
        q = Quote.new(valid_attributes)
        q.should be_valid
        q.save.should be_true
      end
    end

    context "with invalid attributes" do
      it "cannot be saved" do
        q = Quote.new
        q.should_not be_valid
        q.save.should_not be_true
      end
    end
  end
end


describe Quotes do

  describe "add_quote" do
    context "with valid parameters" do
      it "stores the quote" do
        m, quote = valid_parameters 
        expect {
          Quotes.add_quote(m, quote)
        }.to change(Quote, :count).by(1)
      end
    end
  end

  describe "quote" do
    before(:all) do
      1.upto(10) do |i| 
        q = Quote.create(valid_attributes.merge(:quote => i.to_s))
      end

      @m = OpenStruct.new(:channel => "test-hink")
    end

    context "without filter" do
      it "returns a random quote" do
        quote = Quotes.get_random(@m)

        Quote.all.should include(quote)
      end
    end

    context "with filter" do
      it "returns a random quote matching the filter" do
        filter = "1"
        quote = Quotes.get_random(@m, filter)

        quote.quote.should =~ /#{filter}/
      end
    end

    after(:all) do
      Quote.all(:channel => "test-hink").destroy
    end

  end
end
