class CreateReactions < ActiveRecord::Migration[8.1]
  def change
    create_table :reactions do |t|
      t.references :message
      t.references :user
      t.string :reaction_type, null: false

      t.timestamps
    end
  end
end
