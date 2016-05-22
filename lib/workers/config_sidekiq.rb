require 'sidekiq'
require_relative 'zip_worker'

# Sidekiq server setup
Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://redis:6379'  }
end

# Sidekiq client setup
Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://redis:6379'  }
end

# Logging config
Sidekiq::Logging.logger.level = Logger::DEBUG
