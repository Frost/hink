class Hello
  include Cinch::Plugin

  match /hello/i
  react_on :channel

  def execute(m)
    m.reply("hello, #{m.user}!")
  end
end
