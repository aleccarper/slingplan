class AddPriorityToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :priority, :integer
  end
end
