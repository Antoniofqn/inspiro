# config/initializers/sidekiq.rb
#require 'sidekiq-cron'

Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV["REDIS_URL"] || "redis://localhost:6379/0",  # Fallback to localhost for development
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }

  # Load schedule if using Sidekiq-Cron for scheduled tasks
  # schedule_file = Rails.root.join('config', 'schedule.yml')
  # if File.exist?(schedule_file) && Sidekiq.server?
  #   Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  # end
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV["REDIS_URL"] || "redis://localhost:6379/0",
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }
end