class DoAllTheThingsToStaffers < ActiveRecord::Migration
  def change
    change_table :staffers do |t|
      t.string   "stripe_id"
      t.string   "billing_status", default: "active"
      t.string   "name"
      t.string   "country_code"
      t.text     "description"
      t.boolean  "subscribed", default: false, null: false
      t.string   "time_zone"
      t.string   "primary_phone_number"
      t.string   "primary_email"
      t.string   "primary_website"
      t.string   "sign_up_step", default: "card_plan", null: false
      t.string   "cancelation_date"
      t.string   "subscription_id"
      t.boolean  "accepted_terms_of_service"
      t.text     "hidden_hints"
    end

    add_attachment :staffers, :logo_image
  end
end
