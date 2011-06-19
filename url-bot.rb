#!/usr/bin/ruby1.9.1

require 'rubygems'
require 'cinch'
require 'open-uri'
require 'nokogiri'

URLS = File.dirname(__FILE__) + '/../public_html/granen2.html' # relative path to where you want the urls..
NICK = "url-grabber"
SERVER = "irc.freenode.net"
CHANNELS = ["#channel1", "channel2"]

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = NICK
    c.server = SERVER
    c.channels = CHANNELS
  end

  on :channel do |m|
    urls = URI.extract(m.message, /https?/)
    File.open(URLS, 'a') do |f|
      urls.each do |u|
        begin
          puts u
          doc = Nokogiri::HTML(open(u))
          title = doc.at_css("title")
          if title
            title = title.inner_html.gsub(/\s+/, ' ').strip
            m.reply(title)
          end
          puts title
          f.write(%(<a href="#{u}">#{title} - #{u}</a>\n))
        rescue OpenURI::HTTPError => e
          if e.message =~ /^404/ && u =~ /['\)\",.\/]$/
            u = u.gsub(/['\)\",.\/]$/, '')
            puts "trying with #{u}"
            retry
          else
            m.reply('broken url')
          end
        rescue => e
          f.write(%(<a href="#{u}">#{u}</a>\n))
        end
      end
    end
  end
end

bot.start
