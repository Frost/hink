require 'cinch'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-aggregates'
require 'dm-types'

Hink.setup_database

# Data model for Quotes
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
  property :deleted_at, DataMapper::Property::ParanoidDateTime,  required: false
end
Quote.auto_upgrade!

# Cinch plugin used to store and access quotes from a sqlite database
class Quotes
  include Cinch::Plugin

  match(/quote(?: (.*))?/, method: :search_quote)
  match(/spam(?: (.*))?/, method: :search_quote)
  match(/addquote (.*)/, method: :add_quote)
  # match /remember ([^\s]+) (.*)/, method: :remember

  def search_quote(m, filter)
    m.reply(get_random(m, query_filter(filter)))
  end

  def add_quote(m, quote)
    quote = Quote.new(
      added_by: m.user.nick,
      user: m.user.user,
      host: m.user.host,
      channel: m.channel,
      quote: quote
    )

    m.reply(reply_message[quote.save!])
    #
    # if quote.save!
    #   m.reply('Ok')
    # else
    #   m.reply("Nope, can't do that Dave")
    # end
  end

  private

  def reply_message
    {
      true => 'Ok',
      false => "Nope, can't do that Dave"
    }
  end

  def query_filter(filter = nil)
    filter ? filter.gsub(/^(.*)$/, '%\1%') : '%'
  end

  def quote_count(m, filter)
    Quote.count(:channel => m.channel, :quote.like => filter)
  end

  def get_random(m, filter)
    quote = Quote.first(:channel => m.channel,
                        :quote.like => filter,
                        :limit => 1,
                        :offset => rand(quote_count(m, filter))
                       )
    quote ? quote.quote : 'Fuckoff'
  end
end
