class AddServiceRequestSubmittedToEvents < ActiveRecord::Migration
  def change
    add_column :events, :service_request_submitted, :boolean, default: false
  end
end
