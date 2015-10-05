class AddActionToInquiryMessages < ActiveRecord::Migration
  def change
    add_column :inquiry_messages, :action, :string
  end
end
