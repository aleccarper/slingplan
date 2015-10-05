class AddStampsToNegotiationMessages < ActiveRecord::Migration
  def change
    change_table(:negotiation_messages) { |t| t.timestamps }
  end
end
