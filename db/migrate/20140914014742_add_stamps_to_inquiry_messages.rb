class AddStampsToInquiryMessages < ActiveRecord::Migration
  def change
    change_table(:inquiry_messages) { |t| t.timestamps }
  end
end
