json.extract! message, :id, :user_id, :community_id, :parent_message_id, :content, :user_ip, :ai_sentiment_score, :created_at, :updated_at
json.url message_url(message, format: :json)
