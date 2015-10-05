FactoryGirl.define do
  factory :admin do
    sequence(:email) { |n| "admin_#{n}@test.com" }
    sequence(:password) { |n| "admin_#{n}_pw" }
  end
end
