class Hello
  include Cinch::Plugin

  match 'hello'
  react_on :channel

  def execute(m)
    m.reply("hello")
  end
end
