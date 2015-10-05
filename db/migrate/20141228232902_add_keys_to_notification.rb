class AddKeysToNotification < ActiveRecord::Migration
  def change
    change_table :notifications do |t|
      t.references :vendor, index: true
      t.references :user, index: true
    end
  end
end
