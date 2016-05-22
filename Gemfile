source 'https://rubygems.org'

# Ruby version
ruby "2.3.1"

# Parse HTML/XML files
gem "nokogiri", '~> 1.6.7'

# Asynchronous workers
gem "sidekiq", '~> 4.1'

# Zip related operations
gem "rubyzip", '~> 1.2'

group :test, :development do
  # Testing framework
  gem "rspec", '~> 3.4'

  # Code coverage report
  gem "simplecov", '~> 0.11', require: false

  # InMemory Redis (testing purposes)
  gem "fakeredis", '~> 0.5', require: "fakeredis/rspec"

  # Code Climate report
  gem "codeclimate-test-reporter", '~> 0.5', require: nil
end
