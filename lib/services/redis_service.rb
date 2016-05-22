require 'singleton'

class RedisService
  include Singleton

  @@zip_indexes_hash  = 'ZIP_ALREADY_PROCESSED'
  @@news_indexes_hash = 'NEWS_ALREADY_PROCESSED'
  @@news_list         = 'NEWS_XML'

  attr_reader :redis_client

  def initialize
    @redis_client = Redis.new(host: 'redis', port: 6379)
  end

  def zip_already_processed?(zip_hash)
    @redis_client.hexists(@@zip_indexes_hash, zip_hash)
  end

  def news_already_processed?(news_hash)
    @redis_client.hexists(@@news_indexes_hash, news_hash)
  end

  def mark_zip_as_already_processed(zip_hash)
    @redis_client.hset(@@zip_indexes_hash, zip_hash, true)
  end

  def mark_news_as_already_processed(news_hash)
    @redis_client.hset(@@news_indexes_hash, news_hash, true)
  end

  def add_news_to_list(news_content)
    @redis_client.lpush(@@news_list, news_content)
  end

  # Getters for class variables
  def self.zip_indexes_hash;  @@zip_indexes_hash;  end
  def self.news_indexes_hash; @@news_indexes_hash; end
  def self.news_list;         @@news_list;         end
end
