json.extract! reaction, :id, :message_id, :user_id, :reaction_type, :created_at, :updated_at
json.url reaction_url(reaction, format: :json)
