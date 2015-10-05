class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.boolean :read, :default => false
      t.string :title
      t.string :message
      t.string :link

      t.timestamps
    end
  end
end
