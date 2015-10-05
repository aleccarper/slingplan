class AddReadFlagToNegotiationMessages < ActiveRecord::Migration
  def change
    change_table :negotiation_messages do |t|
      t.boolean :read, default: false
    end
  end
end
