FactoryGirl.define do

  factory :event do

    sequence(:name) { |n| "event_#{n}" }
    sequence(:start_date) { |n| Time.now + n.weeks }
    sequence(:end_date) { |n| Time.now + n.weeks + 1.hour }
    country_code 'US'
    city { "state #{rand(36**2).to_s(36)}".upcase }
    state { "state #{rand(36**6).to_s(36)}".titleize }
    confirmed true

    transient do
      planner { create(:planner) }
    end



    before(:create) do |o, e|
      o.planner = e.planner if e.planner
      o.services = Service.all.sample(3)
    end

    after(:create) do |o, e|
      o.service_rfps.each(&:generate_vendor_rfps)
    end
  end
end
