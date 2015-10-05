class AddInquiriesToUsers < ActiveRecord::Migration
  def change
    change_table :inquiries do |t|
      t.references :user, index: true
    end
  end
end
