class ChangeDefaultBidValueToNilOnNegotiationMessages < ActiveRecord::Migration
  def up
    change_column :negotiation_messages, :bid, :integer, default: nil, null: true
  end

  def down
    change_column :negotiation_messages, :bid, :integer
  end
end
