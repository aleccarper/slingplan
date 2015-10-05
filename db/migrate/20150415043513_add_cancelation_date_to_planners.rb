class AddCancelationDateToPlanners < ActiveRecord::Migration
  def change
    add_column :planners, :cancelation_date, :string
  end
end
