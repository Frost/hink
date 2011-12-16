$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib')

require 'webmock/rspec'

RSpec.configure do |c|
  c.fail_fast = false
end
