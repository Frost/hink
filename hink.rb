#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'cinch'
require 'yaml'
$LOAD_PATH << File.dirname(__FILE__) + '/lib'
require 'config'
require 'grabber_helpers'
include GrabberHelpers

# require plugins and libraries
Hink.config[:cinch][:plugins].map do |plugin|
  plugin_file = "plugins/#{underscore(plugin)}"
  require plugin_file
end

bot = Cinch::Bot.new do
  configure do |c|
    cinch = Hink.config[:cinch]
    c.nick = cinch[:nick]
    c.server = cinch[:server]
    c.channels = cinch[:channels]
    c.plugins.plugins = cinch[:plugins].map { |plugin| constantize(plugin) }
  end
end

Hink.setup(bot)

bot.start
