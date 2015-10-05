class CreateInquiries < ActiveRecord::Migration
  def change
    create_table :inquiries do |t|
      t.string :type
      t.string :status, default: 'open'
      t.references :vendor, index: true
    end
  end
end
