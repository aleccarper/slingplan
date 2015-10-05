class AddCompanyNameToPlanners < ActiveRecord::Migration
  def change
    add_column :planners, :company_name, :string
  end
end
