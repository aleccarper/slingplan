class AddUserAndVendorToNegotiationMessages < ActiveRecord::Migration
  def change
    add_reference :negotiation_messages, :user, index: true
    add_reference :negotiation_messages, :vendor, index: true
  end
end
