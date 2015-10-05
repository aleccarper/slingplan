require 'rails_helper'

RSpec.describe Vendor, :type => :model do

  before(:each) do
    @vendor = create(:vendor)
  end

  it 'saves when valid' do
    vendor = build(:vendor)
    expect(vendor.save).to be(true)
  end



  describe '#name' do
    it 'is required' do
      vendor = build(:vendor, name: '')
      expect(vendor.save).to be(false)
    end

    it 'is at least 2 characters' do
      vendor = build(:vendor, name: 'a')
      expect(vendor.save).to be(false)
    end

    it 'is 16 characters or less' do
      vendor = build(:vendor, name: 'testvendortestvendor')
      expect(vendor.save).to be(false)
    end

  end


  describe '#sign_up_step' do
    it 'defaults to card_plan' do
      @vendor = build(:vendor, sign_up_step: nil)
      @vendor.save
      expect(@vendor.sign_up_step).to eq('card_plan')
    end
  end


  describe '#subscribed' do
    it 'defaults to false' do
      @vendor = build(:vendor, subscribed: nil)
      @vendor.save
      expect(@vendor.subscribed).to be(false)
    end
  end



  it { should validate_attachment_content_type(:logo_image).
    allowing('image/png', 'image/gif', 'image/jpeg').
    rejecting('text/plain', 'text/xml', 'image/abc', 'some_image/png') }
end
