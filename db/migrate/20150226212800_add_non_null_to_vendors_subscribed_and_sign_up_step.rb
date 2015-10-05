class AddNonNullToVendorsSubscribedAndSignUpStep < ActiveRecord::Migration
  def up
    change_column(:vendors, :subscribed, :boolean, default: false, null: false)
    change_column(:vendors, :sign_up_step, :string, default: 'card_plan', null: false)
  end

  def down
    change_column(:vendors, :subscribed, :boolean, default: false)
    change_column(:vendors, :sign_up_step, :string, default: 'card_plan')
  end
end
