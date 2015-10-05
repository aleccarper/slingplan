require 'rails_helper'

RSpec.describe Inquiry, :type => :model do

  it 'saves when valid' do
    inquiry = build(:inquiry)
    expect(inquiry.save).to be(true)
  end



  describe '#vendor_id' do

    it 'is required' do
      inquiry = build(:inquiry_without_vendor)
      expect(inquiry.save).to be(false)
    end

  end



  describe '#type' do

    it 'is required' do
      inquiry = build(:inquiry_without_type)
      expect(inquiry.save).to be(false)
    end

  end



  describe '#status' do

    it 'is required' do
      inquiry = build(:inquiry_without_status)
      expect(inquiry.save).to be(false)
    end

  end



  describe '#subject' do

    it 'is required' do
      inquiry = build(:inquiry_without_subject)
      expect(inquiry.save).to be(false)
    end

  end



  describe '#body' do

    it 'is required' do
      inquiry = build(:inquiry_without_body)
      expect(inquiry.save).to be(false)
    end

  end

end
