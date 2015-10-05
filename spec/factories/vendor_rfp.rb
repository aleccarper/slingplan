FactoryGirl.define do

  factory :vendor_rfp do

    before(:create) do |o, e|
      o.location = create(:location, srfp)
    end

    after(:create) do |o, e|
      o.negotiation = create(:negotiation, vendor_rfp: o)
    end
  end
end
