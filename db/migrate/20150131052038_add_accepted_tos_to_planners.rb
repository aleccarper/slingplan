class AddAcceptedTosToPlanners < ActiveRecord::Migration
  def change
    add_column :planners, :accepted_tos, :boolean
  end
end
