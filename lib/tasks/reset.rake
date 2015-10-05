require 'colorize'

namespace :db do

  task :soft_reset => :environment do
    puts 'Backing up previously seeded locations...'.colorize(:cyan)

    @insert_sql_for_previous_seeds = SeedUpload.last.sql_for_insert

    puts 'Resetting database...'.colorize(:cyan)

    puts `rake db:reset`

    puts 'Restoring previously seeded locations...'.colorize(:cyan)

    ActiveRecord::Base.connection.execute(@insert_sql_for_previous_seeds)
  end

end
