class SeedWorker
  include Sidekiq::Worker
  include Spreadsheets

  sidekiq_options retry: false

  def perform(seed_upload_id)
    seed_upload = SeedUpload.find(seed_upload_id)

    SlackModule::API.notify_seed_upload_started(seed_upload)

    @locations, @errors = parse_seed_file(seed_upload)

    unless @errors.blank?
      seed_upload.destroy!
      SlackModule::API.notify_seed_upload_errors(seed_upload, @errors)
      $redis.del('parsing_seed_file')
      return
    end

    seed_upload.sql_for_insert = @locations.map { |l|
      l.class.arel_table.create_insert
      .tap { |im|
        im.insert(l.send(
          :arel_attributes_with_values_for_create,
          l.attribute_names)
        )
      }.to_sql
    }.join('; ')

    seed_upload.save

    @locations.each { |loc| loc.save }

    SlackModule::API.notify_seed_upload_finished(seed_upload, @locations)

    $redis.del('parsing_seed_file')
  end



  private

  def parse_seed_file(seed_upload)
    locations = []
    errors = []

    file_path = if Rails.env.development?
      "#{Rails.root}/public#{seed_upload.file.url}".gsub(/(\?\d+)/, '')
    else
      seed_upload.file.url.gsub(/(\?\d+)/, '')
    end

    parser = Spreadsheets::Parser.new({
      file_path: file_path,
      model: Location,
      column_map: {
        # map a real model attribute to spreadsheet header name
        name: 'Company Name',
        services: 'Service Type',
        address1: 'Street Address 1',
        address2: 'Street Address 2',
        city: 'City',
        state: 'State',
        zip: 'Zip',
        phone_number: 'Phone number',
        website: 'Website',
        email: 'Email Address'
      }
    })

    parser.parse.each do |seed|
      # split comma delimited services if more than 1 service loaded for location
      service_names = seed[:attrs][:services].split(',').map { |s| s.strip }
      # find all Services by services names loaded
      seed[:attrs][:services] = Service.where('name IN (?)', service_names)

      if seed[:attrs][:phone_number].to_s.match(/^(.*?)\.\d$/)
        seed[:attrs][:phone_number] = $1
      end
      if seed[:attrs][:zip].to_s.match(/^(.*?)\.\d$/)
        seed[:attrs][:zip] = $1
      end

      # new up model for loaded attrs and assign to current admin
      loc = Location.new({
        admin: seed_upload.admin,
        status: 'active'
      }.merge(seed[:attrs]))

      loc.full_address = [
        loc.address1,
        loc.address2,
        loc.city,
        loc.state,
        loc.zip.to_s
      ].join(' ')

      # skip to next entry if all is well
      if loc.valid?
        locations << loc
        next
      end

      # create validation error messages for view
      errors << seed.merge({
        messages: loc.errors.messages.map { |msg|
          m = "#{msg[0]} #{msg[1].first}"
          m << " (#{loc[msg]})" unless loc[msg].nil?
          m
        }
      })
    end

    [locations, errors]
  end
end
