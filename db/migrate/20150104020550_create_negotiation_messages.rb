class CreateNegotiationMessages < ActiveRecord::Migration
  def change
    create_table :negotiation_messages do |t|
      t.references :negotiation, index: true
      t.text :content
      t.string :action
    end
  end
end
