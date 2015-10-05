FactoryGirl.define do

  factory :negotiation do

    transient do
      vendor_rfp { create(:vendor_rfp) }
    end

    before(:create) do |o, e|
      vendor_rfp { e.vendor_rfp } if e.vendor_rfp
    end
  end
end
