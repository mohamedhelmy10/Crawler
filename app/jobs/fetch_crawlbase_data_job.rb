class FetchCrawlbaseDataJob < ApplicationJob
  queue_as :default

  def perform
    fetch_parsed_data.each do |data|
      save_data(data)
    end
  end

  private

  def fetch_parsed_data
    response = Faraday.get("#{ENV['STORAGE_API_URL']}/pull", { apikey: ENV['CRAWLBASE_API_KEY'] })
    if response.success?
      JSON.parse(response.body)
    else
      Rails.logger.error("Failed to fetch parsed data, Response: #{response.body}")
      []
    end
  rescue StandardError => e
    Rails.logger.error("Error fetching parsed data, Error: #{e.message}")
    []
  end

  def save_data(data)
    File.open(Rails.root.join('parsed_data.json'), 'a') do |file|
      file.puts(data.to_json)
    end
  rescue StandardError => e
    Rails.logger.error("Error saving data, Error: #{e.message}")
  end
end
