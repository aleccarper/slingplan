class AddInquiryMessagesToUsers < ActiveRecord::Migration
  def change
    add_reference :inquiry_messages, :user, index: true
  end
end
