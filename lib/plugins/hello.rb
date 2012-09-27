class Hello
  include Cinch::Plugin

  match /hello/i
  set(
    react_on: :channel
  )

  def execute(m)
    m.reply("hello, #{m.user}!")
  end
end
