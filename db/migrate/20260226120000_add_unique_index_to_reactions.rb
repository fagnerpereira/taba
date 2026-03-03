class AddUniqueIndexToReactions < ActiveRecord::Migration[8.1]
  def change
    add_index :reactions, [:message_id, :user_id, :reaction_type], unique: true, name: 'index_reactions_on_message_user_and_type'
  end
end
