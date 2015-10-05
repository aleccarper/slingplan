FactoryGirl.define do

  factory :location do

    sequence(:name) { |n| "location #{rand(36**6).to_s(36)}" }
    country_code 'US'
    address1 "1510 War Eagle Dr."
    address2 ""
    city 'Little Rock'
    state 'AR'
    zip 72116
    phone_number '(501) 555-55555'
    status 'active'
    confirmed true

    factory :location_unconfirmed do
      confirmed false
    end
  end
end
