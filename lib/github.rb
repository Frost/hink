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
      reference = GitHub.merge_reference_with_default(reference, m.channel.name)
      url = GitHub.reference_url(reference)
      if not url.nil?
        title, status = UrlGrabber.extract_title bot.logger, url
        m.reply("#{m.user.nick}: #{url} - #{title}")
      end
    end
  end

  def self.extract_references(text)
    references = text.scan(/gh:(?:(?!#)([^\/# ]+))?(?:\/([^# ]+))?(?:\#(\d+))?/)
    references.map{|r| {:account => r[0], :repo => r[1], :issue => (r[2].to_i if r[2])}}
  end

  def self.merge_reference_with_default(reference, channel)
    # Create config hashes if not already defined
    $config[:github] ||= {}
    $config[:github][channel.to_sym] ||= {}

    # Make the default hash complete
    default = {:account => nil, :repo => nil, :issue => nil}.merge($config[:github][channel.to_sym])

    # Merge!
    #reference = default.merge(reference.select{|k,v| !v.nil?})
    if reference[:account].nil?
      reference[:account] = default[:account]

      if reference[:repo].nil?
        reference[:repo] = default[:repo]

        if reference[:issue].nil?
          reference[:issue] = default[:issue]
        end
      end
    end

    reference
  end

  def self.reference_url(reference)
    return if reference[:account].nil?
    url = "https://github.com/#{reference[:account]}"

    if reference[:repo]
      url += "/#{reference[:repo]}"

      if reference[:issue]
        url += "/issues/#{reference[:issue]}"
      end
    end

    url
  end
end
