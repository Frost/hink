require 'cinch'
require 'htmlentities'
require 'config'

class Github
  include Cinch::Plugin

  prefix ''
  match /gh:([^ ]+)/, :method => :execute
  react_on :channel

  def execute(m)
    bot.logger.debug("received github referrence(s): #{m.message}")

    self.class.extract_references(m.message).each do |reference|
      reference = self.class.merge_reference_with_default(reference, m.channel.name)
      url = self.class.reference_url(reference)
      if not url.nil?
        title, status = UrlGrabber.extract_title bot.logger, url
	title.gsub!(/ - Github$/, '')
        m.reply("#{m.user.nick}: #{url} - #{reference[:issue].nil? ? title : title.gsub(/ - Issues.*/, '')}")
      end
    end
  end

  def self.extract_references(text)
    references = text.scan(/\bgh:([\da-zA-Z][-\da-zA-Z]*)(\/[-\da-zA-Z]+)?(#\d+|@[\da-fA-F]+)?\b/)
    references.map{|r| {:account => r[0],
                        :repo => (r[1][1..-1] if r[1]),
                        :issue => (r[2][1..-1].to_i if r[2] and r[2].match(/^#/)),
                        :commit => (r[2][1..-1]     if r[2] and r[2].match(/^@/))}}
  end

  def self.merge_reference_with_default(reference, channel)
    # Create config hashes if not already defined
    Hink.config[:github] ||= {}
    Hink.config[:github][channel.to_sym] ||= {}

    # Make the default hash complete
    default = {:account => nil, :repo => nil, :issue => nil, :commit => nil}.merge(Hink.config[:github][channel.to_sym])

    # Merge!
    #reference = default.merge(reference.select{|k,v| !v.nil?})
    if reference[:account].nil?
      reference[:account] = default[:account]

      if reference[:repo].nil?
        reference[:repo] = default[:repo]

        if reference[:issue].nil?
          reference[:issue] = default[:issue]
        elsif reference[:commit].nil?
          reference[:commit] = default[:commit]
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
      elsif reference[:commit]
        url += "/commit/#{reference[:commit]}"
      end
    end

    url
  end
end
