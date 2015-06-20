require 'redis'
require 'sidekiq'

if ENV["REDISCLOUD_URL"] # Heroku RedisCloud
  $redis = Redis.new(:url => ENV["REDISCLOUD_URL"])
elsif ENV['OPENSHIFT_REDIS_HOST'] # Openshift redis
  puts "Openshift: #{ENV['OPENSHIFT_REDIS_HOST']}:#{ENV['OPENSHIFT_REDIS_PORT']}"
  $redis = Redis.new(:host => ENV['OPENSHIFT_REDIS_HOST'], :port => ENV['OPENSHIFT_REDIS_PORT'], :password => ENV['REDIS_PASSWORD'])
end

if Rails.env.production? && ENV['OPENSHIFT_REDIS_HOST']
  Sidekiq.configure_client do |config|
    config.redis = {:host => ENV['OPENSHIFT_REDIS_HOST'], :port => ENV['OPENSHIFT_REDIS_PORT'], :password => ENV['REDIS_PASSWORD']}
  end
  Sidekiq.configure_server do |config|
    config.redis = {:host => ENV['OPENSHIFT_REDIS_HOST'], :port => ENV['OPENSHIFT_REDIS_PORT'], :password => ENV['REDIS_PASSWORD']}
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Status::ServerMiddleware, expiration: 30.minutes # default
  end
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
end