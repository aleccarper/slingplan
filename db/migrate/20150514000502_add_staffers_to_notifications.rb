class AddStaffersToNotifications < ActiveRecord::Migration
  def change
    change_table :notifications do |t|
      t.references :staffer
    end
  end
end
