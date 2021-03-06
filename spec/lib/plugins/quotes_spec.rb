require "spec_helper"
require 'plugins/quotes'
require "ostruct"

def valid_attributes
  {
    added_by: "Frost",
    user: "frost",
    host: "ceri.se",
    channel: "#test-hink",
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
    channel: "#test-hink"
  )
  allow(m).to receive(:reply)
  return m, "<Frost> Some random boring made-up self-quote"
end

describe Quote do

  describe "creation" do
    context "with valid attributes" do
      it "can be saved" do
        q = Quote.new(valid_attributes)
        expect(q).to be_valid
        expect(q.save).to eq(true)
      end
    end

    context "with invalid attributes" do
      it "cannot be saved" do
        q = Quote.new
        expect(q).to_not be_valid
        expect(q.save).to eq(false)
      end
    end
  end

  describe "deletion paranoia" do
    before(:each) do
      @q = Quote.create(valid_attributes)
    end

    it "sets the deleted_at attribute" do
      @q.destroy

      expect(@q.deleted_at).to_not be_nil
    end

    it "doesn't actually remove the quote" do
      @q.destroy

      expect(repository(:default).adapter.select("SELECT * from quotes WHERE id = #{@q.id}")).to_not be_empty
    end

    it "doesn't show up in an ordinary query" do
      @q.destroy

      expect(Quote.all).to_not include(@q)
    end
  end
end


describe Quotes do
  bot = Cinch::Bot.new

  before(:all) do
    bot.loggers.level = :fatal
    Hink.setup(bot)
  end

  subject { Quotes.new(bot) }

  describe "add_quote" do
    context "with valid parameters" do
      it "stores the quote" do
        m, quote = valid_parameters
        expect {
          subject.add_quote(m, quote)
        }.to change(Quote, :count).by(1)
      end
    end
  end

  describe "search_quote" do
    before(:all) do
      1.upto(10) do |i| 
        Quote.create(valid_attributes.merge(:quote => i.to_s))
      end
    end

    context "without filter" do
      it "returns a random quote" do
        m, _quote = valid_parameters
        expect(m).to receive(:reply) do |reply|
          expect(Quote.all.map(&:quote)).to include(reply)
        end
        subject.search_quote(m, nil)
      end
    end

    context "with filter" do
      it "returns a random quote matching the filter" do
        filter = "1"
        m, _quote = valid_parameters
        expect(m).to receive(:reply) do |reply|
          expect(reply).to match(filter)
        end
        subject.search_quote(m, filter)
      end
    end

    after(:all) do
      repository(:default).adapter.execute("delete from quotes where channel = '#test-hink'")
    end

  end
end
