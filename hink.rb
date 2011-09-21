#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'cinch'
require 'yaml'
$:<< File.dirname(__FILE__) + '/lib'
require 'config'
require 'helpers'
include GrabberHelpers

# require plugins and libraries
Hink.config[:cinch][:plugins].map do |plugin|
  require underscore(plugin)
end


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
