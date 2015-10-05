class AddUuidToInquiries < ActiveRecord::Migration
  def change
    add_column :inquiries, :uuid, :uuid, default: 'uuid_generate_v4()'
  end
end
