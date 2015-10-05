source 'https://rubygems.org'

ruby '2.1.2'

# Server Arch
gem 'pg'
gem 'rack-zippy'
gem 'rails', '4.1.4'
gem 'unicorn'

# Common
gem 'airbrake'
gem 'autoscaler'
gem 'aws-sdk', '< 2.0'
gem 'bcrypt'
gem 'colorize'
gem 'comma', '~> 3.0'
gem 'countries'
gem 'country_select'
gem 'dalli'
gem 'deep_cloneable', '~> 2.0.0'
gem 'devise'
gem 'email_reply_parser'
gem 'geocoder'
gem 'griddler'
gem 'griddler-mandrill'
gem 'momentjs-rails'
gem 'order_as_specified'
gem 'paperclip'
gem 'puma'
gem 'rmagick'
gem 'redcarpet'
gem 'redis'
gem 'rest-client'
gem 'roo'
gem 'rubhub'
gem 'seed-fu'
gem 'sidekiq'
gem 'slack-notifier'
gem 'spreadsheet'
gem 'squirm_rails', require: 'squirm/rails'
gem 'stripe'
gem 'stripe_event'
gem 'topojson-rails'
gem 'will_paginate'
gem 'maskedinput-rails'
gem 'meta-tags'

# Assets
gem 'autoprefixer-rails'
gem 'compass-rails'
gem 'd3-rails'
gem 'fastclick-rails'
gem 'font-awesome-sass'
gem 'handlebars_assets'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'jquery-ui-rails'
gem 'oily_png'
gem 'sass-globbing'
gem 'sass-rails'
gem 'slim'
gem 'sprockets-image_compressor'
gem 'uglifier'
gem 'underscore-rails'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'byebug'
  gem 'guard-livereload'
  gem 'guard-rspec'
  gem 'letter_opener'
  gem 'meta_request'
  gem 'spring'
end

group :staging, :production do
  gem 'heroku'
  gem 'newrelic_rpm'
  gem 'rails_12factor'
  gem 'rack-ssl-enforcer'
end

group :test do
  gem 'capybara-webkit'
  gem 'connection_pool'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'pry-byebug'
  gem 'rb-fsevent'
  gem 'rspec-rails'
  gem 'selenium-webdriver', '>=2.45.0.dev3'
  gem 'stripe-ruby-mock', '~> 2.0.5', require: 'stripe_mock'
  gem 'timecop'
  gem 'rspec-stripe'
end

group :coverage do
  gem 'simplecov', require: false
end
