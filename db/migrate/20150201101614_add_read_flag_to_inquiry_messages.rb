class AddReadFlagToInquiryMessages < ActiveRecord::Migration
  def change
    change_table :inquiry_messages do |t|
      t.boolean :read, default: false
    end
  end
end
