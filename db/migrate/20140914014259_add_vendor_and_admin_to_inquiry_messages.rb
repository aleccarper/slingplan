class AddVendorAndAdminToInquiryMessages < ActiveRecord::Migration
  def change
    add_reference :inquiry_messages, :vendor, index: true
    add_reference :inquiry_messages, :admin, index: true
  end
end
