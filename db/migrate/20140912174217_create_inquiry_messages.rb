class CreateInquiryMessages < ActiveRecord::Migration
  def change
    create_table :inquiry_messages do |t|
      t.text :content
      t.references :inquiry, index: true
    end
  end
end
