require 'nbrb_currency'
require 'shoulda'
require 'rr'
require 'monetize'

RSpec.configure do |config|
  config.mock_with :rr
  config.mock_framework = :rspec
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
