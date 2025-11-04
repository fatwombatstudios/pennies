source "https://rubygems.org"

gem "bootsnap", require: false
gem "dartsass-rails", "~> 0.5.1"
gem "importmap-rails"
gem "jbuilder"
gem "kamal", require: false
gem "propshaft"
gem "puma", ">= 5.0"
gem "rails", "~> 8.0.4"
gem "solid_cable"
gem "solid_cache"
gem "solid_queue"
gem "sqlite3", ">= 2.1"
gem "stimulus-rails"
gem "thruster", require: false
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "factory_bot_rails"
  gem "launchy"
  gem "rspec-rails", "~> 8.0.0"
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
