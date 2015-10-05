require 'rails_helper'

RSpec.describe InquiryMessage, :type => :model do

  it 'saves when valid' do
    message = build(:inquiry_message)
    expect(message.save).to be(true)
  end



  describe '#body' do

    it 'is required' do
      message = build(:inquiry_message_without_content)
      expect(message.save).to be(false)
    end
  end

end
