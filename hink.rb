#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'cinch'
require 'yaml'
require File.dirname(__FILE__) + '/lib/config.rb'
# require plugins and libraries
Dir.glob(File.dirname(__FILE__)+'/lib/*').each {|f| require f}

include GrabberHelpers

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = Hink.config[:cinch][:nick]
    c.server = Hink.config[:cinch][:server]
    c.channels = Hink.config[:cinch][:channels]
    c.plugins.plugins = Hink.config[:cinch][:plugins].map {|plugin| constantize(plugin) }
  end
end

Hink.setup(bot)

bot.start
