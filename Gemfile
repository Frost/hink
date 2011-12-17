source 'http://rubygems.org'

gem 'rake'
gem 'cinch'
gem 'nokogiri'
gem 'htmlentities'
gem 'mechanize'
gem 'httparty'
gem 'liquid'

group :datamapper do # used for Quotes plugin
  gem 'dm-core'
  gem 'dm-migrations'
  gem 'dm-validations'
  gem 'dm-timestamps'
  gem 'dm-aggregates'
end

group :sqlite do
  gem 'sqlite3'
  gem 'dm-sqlite-adapter'
end

group :development, :test do
  gem 'rspec'
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'rb-fsevent', require: false
  gem 'rb-inotify', require: false
  gem 'rb-fchange', require: false
  gem 'webmock'
end
