class AddAcceptedTermsOfServiceToPlanners < ActiveRecord::Migration
  def change
    add_column :planners, :accepted_terms_of_service, :boolean
  end
end
