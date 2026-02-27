class AddConstraintsCorrectlyToExistingTables < ActiveRecord::Migration[8.1]
  def change
    # messages table
    change_column_null :messages, :user_id, false
    change_column_null :messages, :community_id, false
    add_foreign_key :messages, :users
    add_foreign_key :messages, :communities

    # reactions table
    change_column_null :reactions, :user_id, false
    change_column_null :reactions, :message_id, false
    add_foreign_key :reactions, :users
    add_foreign_key :reactions, :messages

    # self reference for messages
    add_foreign_key :messages, :messages, column: :parent_message_id
  end
end
