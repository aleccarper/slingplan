if ENV['COVERAGE'] == 'true'
  require 'simplecov'

  SimpleCov.start
else
  ENV["RAILS_ENV"] ||= 'test'
end

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rails/all'
require 'devise'
require 'timecop'
require 'capybara'
require 'factory_girl_rails'
require "paperclip/matchers"
require 'byebug'
require 'geocoder/results/base'

require 'support/request_helpers'
require 'support/wait_until'
require 'support/database_cleaner'
require 'support/mock_geocoder'

Capybara.default_wait_time = 30

include Warden::Test::Helpers
Warden.test_mode!

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|

  config.use_transactional_fixtures = false

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the end.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies.
  config.order = :random

  # Seed global randomization
  Kernel.srand config.seed

  # rspec-expectations config
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  # rspec-mocks config
  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
    config.include MockGeocoder
  end

  config.include Devise::TestHelpers, :type => :controller

  config.include RequestHelpers
  config.include WaitUntil, type: :feature

  config.include Paperclip::Shoulda::Matchers
  config.include RSpec::Rails::RequestExampleGroup, type: :feature


  config.before(:each) do
    [
      { email: 'test1@admin.com', password: 'testpassword' },
      { email: 'test2@admin.com', password: 'testpassword' }
    ].each { |attrs| Admin.create(attrs) }

    [
      { name:'Catering', description:'' },
      { name:'Transportation', description:'' },
      { name:'Event Rental and Decor', description:'' },
      { name:'Entertainment', description:'' },
      { name:'Recreation and Activities', description:'' },
      { name:'Floral', description:'' },
      { name:'Production and Audio Visual', description:'' },
      { name:'Photographers', description:'' },
      { name:'Venues and Event Space', description:'' }
    ].each { |attrs| Service.create(attrs) }
  end
end
