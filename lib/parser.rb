require 'nokogiri'
require 'open-uri'
require_relative 'workers/zip_worker'

module Parser
  def self.run(http_directory_path)
    # Page load
    page = open(http_directory_path)
    base_uri = page.base_uri

    # Load index page
    html = Nokogiri::HTML(page)

    # Link entries
    entries = html.css('td a')

    # Filter zip entries
    zip_entries = entries.select { |entry| entry['href'].end_with?('.zip') }

    # Send each zip entry to be processed in an
    # asynchronous worker
    zip_entries.each do |entry|
      zip_full_path = URI.join(base_uri, entry['href']).to_s
      ZipWorker.perform_async(zip_full_path)
    end
  end
end
