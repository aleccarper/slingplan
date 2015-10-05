# 12 hours later...
#
# The Problem:
#   https://gist.github.com/josevalim/470808
#
# or more specifically, randomly getting one of these three when running capybara:
#   - PG::UnableToSend: another command is already in progress
#   - undefined method `fields' for nil:NilClass
#   - PG::UnableToSend: socket not open
#
# The Solution:
#   http://devblog.avdi.org/2012/08/31/configuring-database_cleaner-with-rails-rspec-capybara-and-selenium/
RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end
