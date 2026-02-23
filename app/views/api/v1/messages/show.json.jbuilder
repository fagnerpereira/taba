# json.partial! "api/v1/message", message: @message
json.extract! @message, :id, :community_id, :content, :user_ip, :parent_message_id, :ai_sentiment_score
json.created_at @message.created_at.iso8601

json.user do
  json.id @message.user.id
  json.username @message.user.username
end
json.url api_v1_message_url(@message, format: :json)
