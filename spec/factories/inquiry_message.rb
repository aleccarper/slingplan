FactoryGirl.define do
  factory :inquiry_message do

    vendor_id { create(:vendor).id }

    content 'stuff and things'

    factory :inquiry_message_without_content do
      content ''
    end

    factory :inquiry_message_owned_by_admin do
      vendor_id nil
      admin_id { create(:admin).id }
    end

    factory :inquiry_message_owned_by_vendor do
      admin_id nil
      vendor_id { create(:vendor).id }
    end
  end
end
