class AddSubjectToInquiries < ActiveRecord::Migration
  def change
    add_column :inquiries, :subject, :string
  end
end
