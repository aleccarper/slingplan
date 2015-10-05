FactoryGirl.define do

  factory :vendor do

    sequence(:name) { |n| "vendor_#{n}" }
    country_code 'US'
    sequence(:email) { |n| "vendor_#{n}@test.com" }
    sequence(:password) { |n| "vendor_#{n}_pw" }
    accepted_terms_of_service true
    sign_up_step 'completed'
    subscribed true

    factory :vendor_on_card_plan do
      sign_up_step 'card_plan'
    end
  end
end
