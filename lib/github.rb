require 'cinch'
require 'htmlentities'

class GitHub
  include Cinch::Plugin

  prefix ''
  match /gh:([^ ]+)/, :method => :execute
  react_on :channel

  def execute(m)
    bot.logger.debug("received github referrence(s): #{m.message}")
  end
end
