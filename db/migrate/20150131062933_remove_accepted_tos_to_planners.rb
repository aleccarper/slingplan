class RemoveAcceptedTosToPlanners < ActiveRecord::Migration
  def change
    remove_column :planners, :accepted_tos, :boolean
  end
end
