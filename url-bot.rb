#!/usr/bin/ruby1.9.1

require 'rubygems'
require 'bundler/setup'
require 'cinch'
require 'yaml'
# require plugins and libraries
Dir.glob(File.dirname(__FILE__)+'/lib/*').each {|f| require f}

$config = YAML.load(File.read(File.dirname(__FILE__)+'/config.yml'))

include GrabberHelpers

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = $config[:cinch][:nick]
    c.server = $config[:cinch][:server]
    c.channels = $config[:cinch][:channels]
    c.plugins.plugins = $config[:cinch][:plugins].map {|plugin| constantize(plugin) }
  end
end

bot.start
