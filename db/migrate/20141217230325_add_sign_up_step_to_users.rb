class AddSignUpStepToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sign_up_step, :string, default: 'card_plan'
  end
end
