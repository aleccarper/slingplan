# Admins
[
  { email: 'alec@criticalmechanism.com', password: 'alec!@#$slingplan' },
  { email: 'fred@criticalmechanism.com', password: 'fred!@#$slingplan' },
  { email: 'sean@criticalmechanism.com', password: 'sean!@#$slingplan' },
  { email: 'chesney.young@gmail.com', password: 'chesney!@#$slingplan' }
].each { |attrs| Admin.create(attrs) }

# Services
[{
  name: 'Catering',
  description: 'Everyone needs to eat.  Make the meals as memorable as the occasion.'
}, {
  name: 'Entertainment',
  description: 'Set the mood and entertain with musicians, performers, and other talent.'
}, {
  name: 'Event Rental and Decor',
  description: 'Furniture, staging, decorations, and anything else you need for your event.'
}, {
  name: 'Floral',
  description: "Blooms, blossoms, and botanicals to enrich your event's environment."
}, {
  name: 'Lodging',
  description: 'From resorts to motels, all the lodging to keep staff and attendees comfortable.'
}, {
  name: 'Photographers',
  description: 'Capture and memorialize the greatest moments of your event.'
}, {
  name: 'Production and Audio Visual',
  description: 'Turn your photos and videos of the event into something special with post-editing.'
}, {
  name: 'Recreation and Activities',
  description: 'Things to do, places to go, sights to see, and adventures to be had.'
}, {
  name: 'Security',
  description:  "Keep your even't attendees and their property as safe as possible."
}, {
  name: 'Transportation',
  description: 'Busses, chauffeurs, and vehicle rentals to get things moving in style.'
}, {
  name: 'Venues and Event Space',
  description: 'Pick the perfect location and atmosphere to compliment your event.'
}].each { |attrs| Service.create(attrs) }

case Rails.env
when 'development', 'staging'
  # Create Planners
  test_vendors = [
    {
      name: 'test1',
      accepted_terms_of_service: true,
      description: 'test description',
      country_code: 'US',
      email: 'test1@example.com',
      password: 'test1_pw',
      locations: [{
          name: '2 Dine 4 Fine Catering',
          country_code: 'US',
          confirmed: true,
          address1: '3008 Gonzales St',
          address2: '',
          city: 'Austin',
          state: 'TX',
          zip: '78702',
          phone_number: '(512) 467-6600',
          email: 'test@test.com',
          website: 'example.com'
        },
        {
          name: 'CO Loc 2',
          country_code: 'US',
          confirmed: true,
          address1: '130 Main St.',
          address2: '',
          city: 'Dillon',
          state: 'CO',
          zip: '80435',
          phone_number: '970-468-7414',
          email: 'test@test.com',
          website: 'example.com'
        },
        {
          name: 'NYC Loc 6',
          country_code: 'US',
          confirmed: true,
          address1: '385 Grand St',
          address2: '',
          city: 'New York',
          state: 'NY',
          zip: '10002',
          phone_number: '720-385-5138',
          email: 'test@test.com',
          website: 'example.com'
        },
        {
          name: 'NYC Loc 6',
          country_code: 'US',
          confirmed: true,
          address1: '220 36th St',
          address2: '',
          city: 'Brooklyn',
          state: 'NY',
          zip: '11232',
          phone_number: '720-385-5138',
          email: 'test@test.com',
          website: 'example.com'
        }
      ]
    },
    {
      name: 'test2',
      accepted_terms_of_service: true,
      description: 'test description',
      country_code: 'US',
      email: 'test2@example.com',
      password: 'test2_pw',
      primary_website: 'www.primary.com',
      locations: [
        {
          name: 'CO Loc 9',
          country_code: 'US',
          confirmed: true,
          address1: '18190 E Bails Pl',
          address2: '',
          city: 'Aurora',
          state: 'CO',
          zip: '80017',
          phone_number: '303-995-5610',
          email: 'test@test.com'
        },
        {
          name: 'CO Loc 10',
          country_code: 'US',
          confirmed: true,
          address1: '7505 E PEAKVIEW AVE',
          address2: '',
          city: 'ENGLEWOOD',
          state: 'CO',
          zip: '80111',
          phone_number: '303-957-2860',
          email: 'test@test.com'
        }
      ]
    },
    {
      name: 'test3',
      accepted_terms_of_service: true,
      description: 'test description',
      country_code: 'US',
      email: 'test3@example.com',
      password: 'test3_pw',
      locations: [
        {
          name: 'CO Loc 5',
          country_code: 'US',
          confirmed: true,
          address1: '690 Portland Rd',
          address2: '',
          city: 'Monument',
          state: 'CO',
          zip: '80132',
          phone_number: '719-650-2077',
          email: 'test@test.com',
          website: 'example.com'
        },
        {
          name: 'CO Loc 6',
          country_code: 'US',
          confirmed: true,
          address1: '11801 Elm Drive',
          address2: '',
          city: 'Thornton',
          state: 'CO',
          zip: '80233',
          phone_number: '720-385-5138',
          email: 'test@test.com',
          website: 'example.com'
        }
      ]
    },
    #austin texas
    {
      name: 'test4',
      accepted_terms_of_service: true,
      description: 'test description',
      country_code: 'US',
      email: 'test4@example.com',
      password: 'test4_pw',
      locations: [
        {
          name: 'CO Loc 1',
          country_code: 'US',
          confirmed: true,
          address1: '7311 Grandview Ave',
          address2: '',
          city: 'Arvada',
          state: 'CO',
          zip: '80002',
          phone_number: '303-460-9101',
          email: 'test@test.com',
          website: 'example.com'
        },
        {
          name: '34th Street Catering',
          country_code: 'US',
          confirmed: true,
          address1: '1005 W. 34th St.',
          address2: '',
          city: 'Austin',
          state: 'TX',
          zip: '78705',
          phone_number: '(512) 323-2000',
          email: 'test@test.com',
          website: 'example.com'
        }
      ]
    },
    {
      name: 'test5',
      accepted_terms_of_service: true,
      description: 'test description',
      country_code: 'US',
      email: 'test5@example.com',
      password: 'test5_pw',
      locations: [
        {
          name: 'Austin Catering Co.',
          country_code: 'US',
          confirmed: true,
          address1: '1106 W. 38th St.',
          address2: '',
          city: 'Austin',
          state: 'TX',
          zip: '78705',
          phone_number: '(512) 467-8776',
          email: 'test@test.com',
          website: 'example.com'
        },
        {
          name: 'Branch BBQ & Catering',
          country_code: 'US',
          confirmed: true,
          address1: '1779 Wells Branch Parkway, Suite 112',
          address2: '',
          city: 'Austin',
          state: 'TX',
          zip: '78728',
          phone_number: '(512) 990-5282',
          email: 'test@test.com',
          website: 'example.com'
        }
      ]
    },
    {
      name: 'test6',
      accepted_terms_of_service: true,
      description: 'test description',
      country_code: 'US',
      email: 'test6@example.com',
      password: 'test6_pw',
      locations: [
        {
          name: 'Crave Catering',
          country_code: 'US',
          confirmed: true,
          address1: '14611 MoPac Expwy.',
          address2: '',
          city: 'Austin',
          state: 'TX',
          zip: '78728',
          phone_number: '719-650-2077',
          email: 'test@test.com',
          website: 'example.com'
        },
        {
          name: 'Eat Out In Restaurant Catering',
          country_code: 'US',
          confirmed: true,
          address1: '11673 Jollyville Road',
          address2: '',
          city: 'Austin',
          state: 'TX',
          zip: '78759',
          phone_number: '720-385-5138',
          email: 'test@test.com',
          website: 'example.com'
        }
      ]
    },

    #NYC
    {
      name: 'test7',
      accepted_terms_of_service: true,
      description: 'test description',
      country_code: 'US',
      email: 'test7@example.com',
      password: 'test7_pw',
      locations: [
        {
          name: 'NYC Loc 5',
          country_code: 'US',
          confirmed: true,
          address1: '202 Banker St',
          address2: '',
          city: 'Brooklyn',
          state: 'NY',
          zip: '11222',
          phone_number: '719-650-2077',
          email: 'test@test.com',
          website: 'example.com'
        }
      ]
    },
    {
      name: 'test8',
      accepted_terms_of_service: true,
      description: 'test description',
      country_code: 'US',
      email: 'test8@example.com',
      password: 'test8_pw',
      locations: [
        {
          name: 'NYC Loc 5',
          country_code: 'US',
          confirmed: true,
          address1: '555 W 23rd St',
          address2: '',
          city: 'New York',
          state: 'NY',
          zip: '10011',
          phone_number: '719-650-2077',
          email: 'test@test.com',
          website: 'example.com'
        },
        {
          name: 'NYC Loc 6',
          country_code: 'US',
          confirmed: true,
          address1: '820 10th Ave',
          address2: '',
          city: 'New York',
          state: 'NY',
          zip: '10019',
          phone_number: '720-385-5138',
          email: 'test@test.com',
          website: 'example.com'
        }
      ]
    },
    {
      name: 'test9',
      accepted_terms_of_service: true,
      description: 'test description',
      country_code: 'US',
      email: 'test9@example.com',
      password: 'test9_pw',
      locations: [
        {
          name: 'NYC Loc 5',
          country_code: 'US',
          confirmed: true,
          address1: '487 Court Street',
          address2: '',
          city: 'Brooklyn',
          state: 'NY',
          zip: '11231',
          phone_number: '719-650-2077',
          email: 'test@test.com',
          website: 'example.com'
        }
      ]
    }
  ]



  test_vendors.each do |vendor_hash|
    sleep(1)
    vendor = Vendor.find_by_email(vendor_hash[:email])
    if !vendor
      vendor = Vendor.create({
        name: vendor_hash[:name],
        country_code: vendor_hash[:country_code],
        accepted_terms_of_service: vendor_hash[:accepted_terms_of_service],
        email: vendor_hash[:email],
        password: vendor_hash[:password],
        password_confirmation: vendor_hash[:password]
      })
      vendor_hash[:locations].each do | location_hash |
        loc = vendor.locations.new(location_hash)
        loc.full_address = loc.address1 + ' ' + loc.address2 + ' ' + loc.city + ' ' + loc.state + ' ' + loc.zip.to_s

        1.times { loc.services << Service.all.sample }
        loc.save()
      end
    end
  end



  admin_locations = [
    {
      name: 'Catering by Rosemary Inc.',
      country_code: 'US',
      address1: '2110 San Jacinto Blvd',
      address2: '',
      city: 'Austin',
      state: 'TX',
      zip: '78712',
      phone_number: '714-473-3990',
      email: 'test@test.com',
      website: 'example.com'
    },
    {
      name: 'An Affair To Remember Catering',
      country_code: 'US',
      address1: '209 E. Ben White Blvd.',
      address2: '',
      city: 'Austin',
      state: 'TX',
      zip: '78704',
      phone_number: '(512) 443-3422',
      email: 'test@test.com',
      website: 'example.com'
    },
    {
      name: 'CO Loc 7',
      country_code: 'US',
      address1: '5702 Zephyr Street',
      address2: '',
      city: 'Arvada',
      state: 'CO',
      zip: '80002',
      phone_number: '714-473-3990',
      email: 'test@test.com',
      website: 'example.com'
    },
    {
      name: 'CO Loc 3',
      country_code: 'US',
      address1: '12454 W Connecticut Dr',
      address2: '',
      city: 'Lakewood',
      state: 'CO',
      zip: '80228',
      phone_number: '303-590-4733',
      email: 'test@test.com',
      website: 'example.com'
    },
    {
      name: 'G&M Catering Inc.',
      country_code: 'US',
      address1: '904 Vargas Road',
      address2: '',
      city: 'Austin',
      state: 'TX',
      zip: '78741',
      phone_number: '714-473-3990',
      email: 'test@test.com',
      website: 'example.com'
    },
    {
      name: 'CO Loc 11',
      country_code: 'US',
      address1: '4621 Peoria st',
      address2: '',
      city: 'Denver',
      state: 'CO',
      zip: '80239',
      phone_number: '303-957-2860',
      email: 'test@test.com',
      website: 'example.com'
    },
    {
      name: 'NYC Loc 11',
      country_code: 'US',
      address1: '23rd St & Westside Hwy',
      address2: '',
      city: 'New York',
      state: 'NY',
      zip: '10011',
      phone_number: '714-473-3990',
      email: 'test@test.com',
      website: 'example.com'
    },
    {
      name: 'NYC Loc 12',
      country_code: 'US',
      address1: '20 W 55th St',
      address2: '',
      city: 'New York',
      state: 'NY',
      zip: '10019',
      phone_number: '714-473-3990',
      email: 'test@test.com',
      website: 'example.com'
    },
    {
      name: 'NYC Loc 13',
      country_code: 'US',
      address1: '393 W 49th St',
      address2: '',
      city: 'New York',
      state: 'NY',
      zip: '10019',
      phone_number: '714-473-3990',
      email: 'test@test.com',
      website: 'example.com'
    }
  ]

  admin = Admin.first
  admin_locations.each do | location_hash |
    loc = admin.locations.new(location_hash)
    loc.full_address = loc.address1 + ' ' + loc.address2 + ' ' + loc.city + ' ' + loc.state + ' ' + loc.zip.to_s
    1.times { loc.services << Service.all.sample }
    loc.status = 'active'
    loc.save()
    sleep(1)
  end
end
