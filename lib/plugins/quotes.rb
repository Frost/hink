require 'cinch'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require "dm-timestamps"
require "dm-aggregates"

DataMapper.setup(:default, "sqlite://#{File.dirname(__FILE__)}/../../quotes.db")

class Quote
  include DataMapper::Resource

  property :id,         Serial
  property :added_by,   String,   required: true, default: ''
  property :user,       String,   required: true, default: ''
  property :host,       String,   required: true, default: ''
  property :channel,    String,   required: true, default: ''
  property :created_at, DateTime
  property :updated_at, DateTime
  property :quote,      Text,     required: true, lazy: false, default: ''
end
Quote.auto_upgrade!

class Quotes
  include Cinch::Plugin

  match /quote(?: (.*))?/, method: :search_quote
  match /spam(?: (.*))?/, method: :search_quote
  match /addquote (.*)/, method: :add_quote
#  match /remember ([^\s]+) (.*)/, method: :remember
  
  def search_quote(m, filter)
    if quote = self.class.get_random(m, filter)
      m.reply(quote.quote)
    else
      m.reply("Fuckoff")
    end
  end

  def add_quote(m, quote)
    if self.class.add_quote(m, quote)
      m.reply("Ok")
    else
      m.reply("Nope, can't do that Dave")
    end
  end

  class << self
    def add_quote(m, quote)
      q = Quote.new(added_by: m.user.nick, user: m.user.user, host: m.user.host, channel: m.channel, quote: quote)
      q.save
    end

    def get_random(m, filter = nil)
      if filter
        filter = filter.gsub(/^(.*)$/, '%\1%')
      end
      filter ||= "%"
      count = Quote.count(:channel => m.channel, :quote.like => filter)
      Quote.all(:channel => m.channel, :quote.like => filter, :limit => 1, :offset => rand(count)).first
    end
  end
end
