source "https://rubygems.org"

gem "rails", "~> 8.1.2"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false
gem "image_processing", "~> 1.2"

# Auth
gem "devise"
gem "devise-jwt"

# Authorization
gem "pundit"

# Serialization
gem "alba"

# Pagination
gem "pagy"

# Money handling
gem "money-rails"

# Slugs
gem "friendly_id"

# State machine (orders)
gem "aasm"

# Image uploads (Active Storage with S3)
gem "aws-sdk-s3", require: false

# CORS
gem "rack-cors"

# API Documentation
gem "rswag-api"
gem "rswag-ui"

# Redis
gem "redis"

# Background jobs
gem "sidekiq"

# Soft delete
gem "discard"

# Password hashing for customers
gem "bcrypt", "~> 3.1.22"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false

  # Testing
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "shoulda-matchers"
  gem "database_cleaner-active_record"
  gem "simplecov", require: false
  gem "rswag-specs"
end
