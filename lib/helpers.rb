module GrabberHelpers
  def constantize(name)
    c = Object
    c.const_defined?(name) ? c.const_get(name) : c.const_missing(name)
  end
end

