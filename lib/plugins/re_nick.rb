# try to regain lost nickname
class ReNick
  include Cinch::Plugin

  timer(30, method: :renick)

  def renick
    nick = Hink.config[:cinch][:nick]
    Hink.bot.nick = nick if nick
  end
end
