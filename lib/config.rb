class Hink
  config_file = File.join(File.dirname(__FILE__), "..", "config.yml")
  @@config = YAML.load(File.read(config_file))

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
    db_file = File.join(File.dirname(__FILE__), "..", "hink.sqlite3")
    DataMapper.setup(:default, "sqlite://#{db_file}")
  end
end

