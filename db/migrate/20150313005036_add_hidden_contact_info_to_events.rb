class AddHiddenContactInfoToEvents < ActiveRecord::Migration
  def change
    add_column :events, :hidden_contact_info, :text
  end
end
