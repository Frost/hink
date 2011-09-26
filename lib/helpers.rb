module GrabberHelpers
  def constantize(name)
    c = Object
    c.const_defined?(name) ? c.const_get(name) : c.const_missing(name)
  end

  def underscore(name)
    words = []
    name.scan(/([A-Z][a-z]+)/) {|match| words << match[0].downcase}
    words.join('_')
  end

  def genitive(nick)
	 if nick[-1] == "s"
	 	"#{nick}'"
	 else
	 	"#{nick}'s"
	 end
  end
end

