class Message < ApplicationRecord
  # TODO: Validações implementadas
  validates :content, presence: true
  validates :user_ip, presence: true

  belongs_to :user
  belongs_to :community
  belongs_to :parent_message, class_name: "Message", optional: true
  has_many :replies, class_name: "Message", foreign_key: "parent_message_id", dependent: :destroy
  has_many :reactions, dependent: :destroy

  # TODO: POST /api/v1/messages (criar mensagem + sentiment)
  # Sentiment analysis is triggered before save or via job as per ARCHITECTURE_IDEAS
  before_save :analyze_sentiment, if: :content_changed?

  # TODO: GET /api/v1/communities/:id/messages/top
  # Engajamento = (reactions * 1.5) + (replies * 1.0)
  def self.top_messages_for_community(community_id, limit = 10)
    where(community_id: community_id, parent_message_id: nil)
      .includes(:user)
      .left_joins(:reactions, :replies)
      .group(:id)
      .select("messages.*, 
               (COUNT(DISTINCT reactions.id) * 1.5 + COUNT(DISTINCT replies_messages.id) * 1.0) AS computed_engagement_score,
               COUNT(DISTINCT reactions.id) as reactions_count,
               COUNT(DISTINCT replies_messages.id) as replies_count")
      .order("computed_engagement_score DESC")
      .limit(limit)
  end

  private

  def analyze_sentiment
    # Referring to TODO: POST /api/v1/messages (criar mensagem + sentiment)
    self.ai_sentiment_score = SentimentAnalyzer.analyze(content)
  end
end
