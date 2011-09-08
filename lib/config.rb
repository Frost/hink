class Hink
  @@config = YAML.load(File.read(File.dirname(__FILE__)+'/../config.yml'))
  def self.config
    @@config
  end
end

