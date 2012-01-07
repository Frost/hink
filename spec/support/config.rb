class Hink
  @@config = YAML.load(File.read(File.dirname(__FILE__)+'/../../config.yml.test'))

  def self.setup(bot)
    @@bot = bot
  end

  def self.config
    @@config
  end

  def self.bot
    @@bot
  end

  def self.setup_database
    DataMapper.setup(:default, "sqlite://#{File.dirname(__FILE__)}/../hink.sqlite3")
  end
end

