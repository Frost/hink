class Hink
  @@config = YAML.load(File.read(File.dirname(__FILE__)+'/../config.yml'))

  def self.setup(bot)
    @@bot = bot
  end

  def self.config
    @@config
  end

  def self.bot
    @@bot
  end
end

