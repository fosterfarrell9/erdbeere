Sidekiq.configure_client do |config|
  Rails.application.config.after_initialize do
    CachePopulator.perform_async
  end
end