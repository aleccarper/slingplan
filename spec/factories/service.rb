FactoryGirl.define do
  factory :service do
    sequence(:name) { |n| "Service #{rand(36**6).to_s(36)}" }

    factory :service_without_name do
      name ''
    end
  end
end
