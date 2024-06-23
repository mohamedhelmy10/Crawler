require 'faraday'
require 'parallel'
require 'logger'

class CrawlerPusher

  def initialize(file_path)
    @file_path = file_path
    @logger = Logger.new(STDOUT)
  end

  def push_urls
    urls = read_urls
    Parallel.each(urls, in_threads: 5) do |url|
      push_url(url)
    end
  end

  private

  def read_urls
    File.readlines(@file_path).map(&:chomp)
  end

  def push_url(url)
    response = Faraday.post("#{ENV['CRAWLBASE_API_URL']}/crawl", { url: url, autoparse: true }.to_json, { 'Content-Type' => 'application/json', 'apikey' => ENV['API_KEY'] })
    if response.success?
      @logger.info("Successfully pushed URL: #{url}")
    else
      @logger.error("Failed to push URL: #{url}, Response: #{response.body}")
    end
  rescue StandardError => e
    @logger.error("Error pushing URL: #{url}, Error: #{e.message}")
  end
end
