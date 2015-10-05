class AddIsServiceRequestToInquiries < ActiveRecord::Migration
  def change
    add_column :inquiries, :is_service_request, :boolean, default: false
  end
end
