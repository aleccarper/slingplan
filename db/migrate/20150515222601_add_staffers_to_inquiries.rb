class AddStaffersToInquiries < ActiveRecord::Migration
  def change
    change_table :inquiries do |t|
      t.references :staffer, index: true
    end
    change_table :inquiry_messages do |t|
      t.references :staffer, index: true
    end
  end
end
