class AddBodyToInquiries < ActiveRecord::Migration
  def change
    add_column :inquiries, :body, :text
  end
end
