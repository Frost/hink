require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib')

require 'webmock/rspec'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |c|
  c.fail_fast = false

  # whitelist codeclimate.com so test coverage can be reported
  c.after(:suite) do
    WebMock.disable_net_connect!(:allow => 'codeclimate.com')
  end
end

