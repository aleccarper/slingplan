FactoryGirl.define do

  factory :planner do

    sequence(:first_name) { |n| "first#{n}" }
    sequence(:last_name) { |n| "last#{n}" }
    country_code 'US'
    sequence(:email) { |n| "planner_#{n}@test.com" }
    password "test1234"
    password_confirmation "test1234"
    accepted_terms_of_service true
    settings { create(:settings) }



    after(:create) do |o|
      o.events << create(:event, planner: o)
    end
  end
end
