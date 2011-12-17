class ReNick
  include Cinch::Plugin

  timer 30, :method => :renick

  def renick
    unless Hink.bot.nick == Hink.config[:cinch][:nick]
      Hink.bot.nick= Hink.config[:cinch][:nick]
    end
  end
end
