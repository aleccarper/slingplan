class RenameUserToPlanner < ActiveRecord::Migration

  @@relations = [
    :events,
    :inquiries,
    :inquiry_messages,
    :negotiations,
    :negotiation_messages,
    :notifications
  ]

  def self.up
    rename_table :users, :planners

    @@relations.each do |t|
      rename_column t, :user_id, :planner_id
    end
  end

 def self.down
    rename_table :planners, :users

    @@relations.each do |t|
      rename_column t, :planner_id, :user_id
    end
 end
end
