require "spec_helper"
require "services/redis_service"

RSpec.describe RedisService do
  let(:redis_service) { RedisService.instance      }
  let(:redis_client)  { redis_service.redis_client }

  after(:each) do
    redis_client.flushall
  end

  context "zip file" do
    let(:zip_hash) { SecureRandom.hex }

    it "recognize an already processed zip" do
      expect(redis_service.zip_already_processed?(zip_hash)).to be false
      redis_client.hset('ZIP_ALREADY_PROCESSED', zip_hash, true)
      expect(redis_service.zip_already_processed?(zip_hash)).to be true
    end

    it "mark a zip as processed" do
      expect(redis_client.hexists('ZIP_ALREADY_PROCESSED', zip_hash)).to be false
      redis_service.mark_zip_as_already_processed(zip_hash)
      expect(redis_client.hexists('ZIP_ALREADY_PROCESSED', zip_hash)).to be true
    end
  end

  context "news file" do
    let(:news_hash) { SecureRandom.hex }

    it "recognize an already processed news file" do
      expect(redis_service.news_already_processed?(news_hash)).to be false
      redis_client.hset('NEWS_ALREADY_PROCESSED', news_hash, true)
      expect(redis_service.news_already_processed?(news_hash)).to be true
    end

    it "mark a news file as processed" do
      expect(redis_client.hexists('NEWS_ALREADY_PROCESSED', news_hash)).to be false
      redis_service.mark_news_as_already_processed(news_hash)
      expect(redis_client.hexists('NEWS_ALREADY_PROCESSED', news_hash)).to be true
    end
  end

  context "add news to Redis" do
    let(:news_content) { SecureRandom.hex }

    it "add news content to list" do
      expect(redis_client.llen('NEWS_XML')).to eq(0)
      redis_service.add_news_to_list(news_content)
      expect(redis_client.llen('NEWS_XML')).to eq(1)

      # Check content
      content_in_list = redis_client.lindex('NEWS_XML', 0)
      expect(content_in_list).to eq(news_content)
    end
  end
end
