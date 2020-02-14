Sidekiq.configure_client do |config|
  Rails.application.config.after_initialize do
    CachePopulator.perform_async
  end

  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes
end

Sidekiq.configure_server do |config|
  # see https://stackoverflow.com/questions/17837923/queue-sidekiq-job-on-rails-app-start
  config.on(:startup) do
    already_scheduled = Sidekiq::ScheduledSet.new.any? do |job|
      job.klass == "CachePopulator"
    end
    CachePopulator.perform_async unless already_scheduled
  end

  # accepts :expiration (optional)
  Sidekiq::Status.configure_server_middleware config, expiration: 30.minutes

  # accepts :expiration (optional)
  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes
end