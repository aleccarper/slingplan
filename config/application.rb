require File.expand_path('../boot', __FILE__)

require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SlingPlan
  class Application < Rails::Application

    initializer 'setup_asset_pipeline', group: :all  do |app|
      app.config.assets.precompile.shift
      app.config.assets.precompile.push(Proc.new do |path|
        File.extname(path).in? [
          '.html', '.erb', '.haml',                 # Templates
          '.png',  '.gif', '.jpg', '.jpeg',         # Images
          '.mp4',  '.webm',                         # Movies
          '.eot',  '.otf', '.svc', '.woff', '.ttf', # Fonts
        ]
      end)
    end

    Dir.glob("#{Rails.root}/app/assets/images/**/").each do |path|
      config.assets.paths << path
    end

    config.assets.precompile += %w( map.js )

    config.exceptions_app = self.routes

    config.assets.paths << "#{Rails.root}/app/assets/videos"

    config.autoload_paths += Dir["#{Rails.root}/lib/**/"]

    config.time_zone = 'Central Time (US & Canada)'
    config.active_record.default_timezone = :local

    # http://stackoverflow.com/questions/5267998/rails-3-field-with-errors-wrapper-changes-the-page-appearance-how-to-avoid-t
    config.action_view.field_error_proc = Proc.new { |html_tag, instance|
      html_tag
    }
  end
end
