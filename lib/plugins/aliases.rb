require 'cinch'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-aggregates'

Hink.setup_database

# Data model for Alias
class Alias
  include DataMapper::Resource

  property :trigger,    String, required: true,
                                unique: true,
                                default: '',
                                key: true
  property :target,     Text,   required: true, lazy: false, default: ''
  property :added_by,   String, required: true, default: ''
  property :user,       String, required: true, default: ''
  property :host,       String, required: true, default: ''
  property :channel,    String, required: true, default: ''
  property :created_at, DateTime
  property :updated_at, DateTime
end
Alias.auto_upgrade!

# Cinch plugin for getting/setting aliases
class Aliases
  include Cinch::Plugin

  match(/alias\s*$/i, method: :list_alias)
  match(/alias (\w+) (.*)/i, method: :add_alias)
  match(/^~(\w+)/i, method: :search_alias, use_prefix: false)

  set react_on: :channel

  def search_alias(m, trigger)
    a = Alias.get(trigger.downcase)
    m.reply("#{m.user.nick}: #{a.target}") if a
  end

  def add_alias(m, trigger, target)
    return m.reply("~#{trigger} finns redan") if Alias.get(trigger.downcase)

    new_alias = Alias.new(
      added_by: m.user.nick,
      user: m.user.user,
      host: m.user.host,
      channel: m.channel,
      trigger: trigger.downcase,
      target: target
    )

    m.reply(new_alias.save ? "Ok, #{target} saved at ~#{trigger}" : 'Nope :(')
  end
end
