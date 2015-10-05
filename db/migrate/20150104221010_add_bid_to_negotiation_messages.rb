class AddBidToNegotiationMessages < ActiveRecord::Migration
  def change
    change_table :negotiation_messages do |t|
      t.integer :bid
    end
  end
end
