class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :user
      t.references :community
      t.bigint :parent_message_id
      t.text :content, null: false
      t.string :user_ip, null: false
      t.float :ai_sentiment_score

      t.timestamps
    end
  end
end
