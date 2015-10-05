class ChangeDefaultToOpenOnInquiries < ActiveRecord::Migration
  def up
    change_column :inquiries, :status, :string, default: 'open'
  end

  def down
    change_column :inquiries, :status, :string, default: 'pending'
  end
end
