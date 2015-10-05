class AddSignUpStepToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :sign_up_step, :string, default: 'card_plan'
  end
end
