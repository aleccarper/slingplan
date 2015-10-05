FactoryGirl.define do

  factory :service_rfp do

    transient do
      event { create(:event) }
    end

    before(:create) do |o, e|
      event { e.event } if e.event
      o.service = Service.all.sample
    end
  end
end
