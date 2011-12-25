require "cinch"
require "dm-core"
require "dm-migrations"
require "dm-validations"
require "dm-timestamps"
require "dm-aggregates"

Hink.setup_database

class Alias
  include DataMapper::Resource

  property :trigger,    String, required: true, unique: true, default: '', key: true
  property :target,     Text,   required: true, lazy: false, default: ''
  property :added_by,   String, required: true, default: ''
  property :user,       String, required: true, default: ''
  property :host,       String, required: true, default: ''
  property :channel,    String, required: true, default: ''
  property :created_at, DateTime
  property :updated_at, DateTime
end
Alias.auto_upgrade!

class Aliases
  include Cinch::Plugin

  match /alias\s*$/i, method: :list_alias
  match /alias (\w+) (.*)/i, method: :add_alias
  match /^~(\w+)/i, method: :search_alias, use_prefix: false

  react_on :channel

  def search_alias(m, trigger)
    a = Alias.get(trigger)
    if a
      m.reply("#{m.user.nick}: #{a.target}")
    end
  end

  def add_alias(m, trigger, target)
    new_alias = Alias.new(
      added_by: m.user.nick,
      user: m.user.user,
      host: m.user.host,
      channel: m.channel,
      trigger: trigger,
      target: target
    )
    if new_alias.save
      m.reply("Ok, #{target} saved at ~#{trigger}")
    else
      if new_alias.errors[:trigger].any?
        m.reply("~#{trigger} finns redan")
      else
        m.reply("Nope :(")
      end
    end
  end
end
