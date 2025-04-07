source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.0"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Frontend and assets
# gem "jsbundling-rails"
gem "cssbundling-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tailwindcss-rails", "~> 4.2"

# Database and caching
gem "redis", ">= 4.0.1"
gem "kredis"
gem "solid_cache"

# Background processing
gem "solid_queue"
gem "sidekiq"

# File processing
gem "image_processing", "~> 1.2"
gem "bootsnap", require: false

# Authentication and authorization
gem "devise", "~> 4.9"

# Rich text editor
gem "actiontext", require: "action_text"
gem "tinymce-rails"

# Payment processing
gem "stripe", "~> 9.0"
gem "pay", "~> 6.0"
gem "paypal-sdk-rest"

# UI Components
gem "view_component"

# PDF generation
gem "prawn"
gem "prawn-table"
gem "ttfunk"
gem "prawn-templates"
gem "prawn-svg"
gem "prawn-icon"
gem "prawn-html"

# Performance improvements
gem "oj"
gem "connection_pool"

group :development, :test do
  gem "debug", platforms: %i[ mri ]
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
end

group :development do
  gem "web-console"
  gem "better_errors"
  gem "binding_of_caller"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

# Pagination
gem "kaminari"
