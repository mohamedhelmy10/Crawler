require 'json'
require 'csv'
require 'logger'

class CrawlerExporter
  def initialize
    @logger = Logger.new(STDOUT)
  end

  def export_to_csv
    data = read_json_data
    convert_to_csv(data)
  end

  private

  def read_json_data
    File.readlines('parsed_data.json').map { |line| JSON.parse(line) }
  rescue StandardError => e
    @logger.error("Error reading JSON data, Error: #{e.message}")
    []
  end

  def convert_to_csv(data)
    CSV.open('parsed_data.csv', 'w') do |csv|
      csv << data.first.keys # Add headers
      data.each { |hash| csv << hash.values }
    end
    @logger.info("Data successfully exported to CSV")
  rescue StandardError => e
    @logger.error("Error converting data to CSV, Error: #{e.message}")
  end
end
