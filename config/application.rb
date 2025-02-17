require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Crawler
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.active_job.queue_adapter = :sidekiq

    Sidekiq.configure_server do |config|
      config.on(:startup) do
        schedule_file = "config/sidekiq-scheduler.yml"

        if File.exist?(schedule_file)
          Sidekiq::Scheduler.dynamic = true
          Sidekiq.schedule = YAML.load_file(schedule_file)
          Sidekiq::Scheduler.reload_schedule!
        end
      end
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
