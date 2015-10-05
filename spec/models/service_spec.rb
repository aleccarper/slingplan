require 'rails_helper'

describe Service do

  let(:valid_service_name) { 'ButtMassage' }

  it 'saves when valid' do
    service = build(:service, name: valid_service_name)
    expect(service.save).to be(true)
  end


  describe '#name' do

    it 'is required' do
      service = build(:service_without_name)
      expect(service.save).to be(false)
    end

    it 'is not a case-insensitive duplicate' do
      service = create(:service, name: valid_service_name)
      dup = build(:service, name: valid_service_name.downcase)
      expect(dup.save).to be(false)
    end

  end

  describe '#with_vendor_locations' do

    let(:location) { create(:location_owned_by_vendor) }

    it 'acknowledges vendor locations' do
      service = build(:service, name: valid_service_name)
      expect(service.save).to be(true)
    end
  end

end
