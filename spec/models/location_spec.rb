require 'rails_helper'

RSpec.describe Location, type: :model do

  before do
    mock_geocoding!
  end

  describe '#owned_by_class?' do
    context "admin owned" do
      before do
        @location = create(:location, admin: create(:admin))
      end

      it 'returns true for :admin' do
        expect(@location.owned_by_class?(:admin)).to be(true)
      end

      it 'returns false for :vendor' do
        expect(@location.owned_by_class?(:vendor)).to be(false)
      end
    end

    context "vendor owned" do
      before do
        @location = create(:location, vendor: create(:vendor))
      end

      it 'returns false for :admin' do
        expect(@location.owned_by_class?(:admin)).to be(false)
      end

      it 'returns true for :vendor' do
        expect(@location.owned_by_class?(:vendor)).to be(true)
      end
    end
  end

  describe '#country_code' do
    it 'is required' do
      location = build(:location, country_code: '')
      expect(location.save).to be(false)
    end
  end

  describe '#services' do

    it 'is not duplicated' do
      service = Service.first
      location = build(:location, vendor: create(:vendor), services: [service])

      expect(location.valid?).to eq(true)

      location.services << service

      expect(location.valid?).not_to eq(true)
    end
  end

end
