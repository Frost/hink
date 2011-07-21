require 'cinch'
require 'htmlentities'

class GitHub
  include Cinch::Plugin

  prefix ''
  match /gh:([^ ]+)/, :method => :execute
  react_on :channel

  def execute(m)
    bot.logger.debug("received github referrence(s): #{m.message}")

    GitHub.extract_references(m.message).each do |reference|
      reference = GitHub.merge_reference_with_default(reference, m.channel)
      url = GitHub.reference_url(reference)
      title, status = UrlGrabber.extract_title bot.logger, url
      m.reply("#{m.user.nick}: #{url} - #{title}")
    end
  end

  def self.extract_references(text)
    references = text.scan(/gh:(?:(?!#)([^\/# ]+))?(?:\/([^# ]+))?(?:\#(\d+))?/)
    references.map{|r| {:account => r[0], :repo => r[1], :issue => (r[2].to_i if r[2])}}
  end

  def self.merge_reference_with_default(reference, channel)
    $config[:github] ||= {}
    $config[:github][channel.name.to_sym] ||= {}

    default = {:account => nil, :repo => nil, :issue => nil}.merge($config[:github][channel.name.to_sym])

    reference = default.merge(reference.select{|k,v| !v.nil?})
  end

  def self.reference_url(reference)
    url = "https://github.com/#{reference[:account]}"
    url += "/#{reference[:repo]}" if reference[:repo]
    url += "/issues/#{reference[:issue]}" if reference[:issue]
    url
  end
end
