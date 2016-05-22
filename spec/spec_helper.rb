require "securerandom"
require "fakeredis"
require "sidekiq/testing"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.order = :random

  # Cleanup Redis before running next spec
  config.before(:all) do
    RedisService.instance.redis_client.flushall
  end
end

# Disable Sidekiq log in testing mode
Sidekiq::Logging.logger = nil

