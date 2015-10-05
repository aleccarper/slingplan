class AddStampsToInquiries < ActiveRecord::Migration
  def change
    change_table(:inquiries) { |t| t.timestamps }
  end
end
