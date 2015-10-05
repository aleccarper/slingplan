class AddKeyWordsToServices < ActiveRecord::Migration
  def change
    add_column :services, :key_words, :string
  end
end
