require 'open-uri'
require 'zip'
require 'sidekiq'
require_relative '../services/redis_service'

class ZipWorker
  include Sidekiq::Worker

  def initialize
    @redis = RedisService.instance
  end

  def perform(zip_path)
    zip_name = File.basename(zip_path)
    zip_hash = File.basename(zip_path, '.zip')

    if @redis.zip_already_processed?(zip_hash)
      logger.debug "[#{zip_name}] Zip file already processed! Skipping..."
      return
    end

    logger.info "[#{zip_name}] Downloading zip..."
    zip_stream = open(zip_path)

    Zip::File.open(zip_stream) do |zip_file|
      zip_file.each do |entry|
        logger.info "[#{zip_name}] Processing inner file: #{entry.name}"
        process_xml_file(entry)
      end
    end

    @redis.mark_zip_as_already_processed(zip_hash)
    logger.info "[#{zip_name}] Finished!"
  end

  private
    def process_xml_file(entry)
      xml_hash     = File.basename(entry.name, '.xml')
      file_content = entry.get_input_stream.read

      if @redis.news_already_processed?(xml_hash)
        logger.debug "[#{entry.name}] News file already processed! Skipping..."
        return
      end

      @redis.add_news_to_list(file_content)
      @redis.mark_news_as_already_processed(xml_hash)
    end
end
