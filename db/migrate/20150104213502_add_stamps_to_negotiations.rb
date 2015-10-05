class AddStampsToNegotiations < ActiveRecord::Migration
  def change
    change_table(:negotiations) { |t| t.timestamps }
  end
end
