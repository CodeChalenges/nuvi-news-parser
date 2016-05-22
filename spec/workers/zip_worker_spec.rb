require "spec_helper"
require "workers/zip_worker"

RSpec.describe ZipWorker do
  let(:worker)        { ZipWorker.new }
  let(:zip_location)  { File.join(File.dirname(__FILE__), '../fixtures/abcdef.zip') }
  let(:redis_service) { RedisService.instance }
  let(:redis_client)  { redis_service.redis_client }

  # Hashes
  let(:zip_hash) { 'abcdef' }
  let(:xml_hash) { '123456' }

  context "perform" do
    it { expect(redis_service.zip_already_processed?(zip_hash)).to be false }
    it { expect(redis_service.news_already_processed?(xml_hash)).to be false }
    it { expect(redis_client.llen(RedisService.news_list)).to be_zero }

    context "process xml file" do
      before { worker.perform(zip_location) }

      it { expect(redis_service.zip_already_processed?(zip_hash)).to be true  }
      it { expect(redis_service.news_already_processed?(xml_hash)).to be true }
      it { expect(redis_client.llen(RedisService.news_list)).to eq(1) }

      it "don't duplicate news" do
        worker.perform(zip_location)
        expect(redis_client.llen(RedisService.news_list)).to eq(1)
      end
    end
  end

  context "sidekiq queue" do
    before {
      # Enable Sidekiq fake mode (push all jobs in an array instead of Redis)
      Sidekiq::Testing.fake!
    }

    it "enqueue job" do
      expect{
        ZipWorker.perform_async('any_zip.zip')
      }.to change(ZipWorker.jobs, :size).by(1)
    end
  end
end
