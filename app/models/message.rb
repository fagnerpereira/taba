class Message < ApplicationRecord
  POSITIVE_WORDS = %w[bom boa excelente ótimo maravilhoso feliz alegre positivo legal massa top show good great amazing happy].freeze
  NEGATIVE_WORDS = %w[ruim péssimo horrível triste negativo chato bosta lixo odiei desastre bad awful horrible sad negative].freeze

  belongs_to :user
  belongs_to :community
  belongs_to :parent_message, class_name: "Message", optional: true

  has_many :replies,
    class_name: "Message",
    foreign_key: "parent_message_id",
    dependent: :destroy
  has_many :reactions, dependent: :destroy

  attribute :username, :string
  validates :username, :content, :user_ip, presence: true

  before_validation :set_user
  before_create :analyze_sentiment

  # Custom SentimentAnalyzer - Sentiment analysis in Portuguese/English
  # TODO: Implement with AI if there is some time
  def analyze_sentiment
    return 0.0 if content.blank?

    words = content.downcase.scan(/\w+/)
    positive_count = (words & POSITIVE_WORDS).size
    negative_count = (words & NEGATIVE_WORDS).size

    total_matches = positive_count + negative_count
    return 0.0 if total_matches.zero?

    # Score between -1.0 and 1.0
    (positive_count - negative_count).to_f / total_matches
  end

  private

  def set_user
    self.user = User.find_or_create_by!(username: username) if username.present?
  end
end
