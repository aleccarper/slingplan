class AddPhoneEmailAndWebsiteToPlanners < ActiveRecord::Migration
  def change
    add_column :planners, :primary_phone_number, :string
    add_column :planners, :primary_email, :string
    add_column :planners, :primary_website, :string
  end
end
