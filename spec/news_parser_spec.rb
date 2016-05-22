require "spec_helper"
require "news_parser"

RSpec.describe NewsParser do
  let(:http_directory_path)  { 'http://bitly.com/nuvi-plz' }
  let(:expected_zip_entries) {
    Nokogiri::HTML(open(http_directory_path))
              .css('td a')
              .select { |entry| entry['href'].end_with?('.zip') }
              .length
  }

  # Enable Sidekiq fake mode (push all jobs in an array instead of Redis)
  before { Sidekiq::Testing.fake! }

  it "don't have any pending job" do
    expect(ZipWorker.jobs.size).to be_zero
  end

  context "run" do
    before { NewsParser.run(http_directory_path) }

    it "creates a job for each zip entry" do
      expect(ZipWorker.jobs.size).to eq(expected_zip_entries)
    end
  end
end
