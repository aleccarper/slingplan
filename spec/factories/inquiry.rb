FactoryGirl.define do
  factory :inquiry do

    vendor_id { create(:vendor).id }

    type 'question'
    status 'pending'
    subject 'limpness'
    body "Oh god my weiner doesn't work"

    factory :inquiry_without_vendor do
      vendor_id nil
    end

    factory :inquiry_without_status do
      status ''
    end

    factory :inquiry_without_type do
      type ''
    end

    factory :inquiry_without_subject do
      subject ''
    end

    factory :inquiry_without_body do
      body ''
    end
  end
end
