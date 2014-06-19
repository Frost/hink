require 'htmlentities'

module GrabberHelpers
  def constantize(name)
    c = Object
    c.const_defined?(name) ? c.const_get(name) : c.const_missing(name)
  end

  def underscore(name)
    name = name.gsub(' ','_')
    if name =~ /[A-Z]/
      words = []
      name.scan(/([A-Z][a-z]+)/) {|match| words << match[0].downcase}
      return words.join('_')
    else
      return name
    end
  end

  def sanitize_title(title)
    HTMLEntities.new.decode(title).gsub(/\s+/, ' ').strip
  end
end

