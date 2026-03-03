class SentimentAnalyzer
  # TODO: POST /api/v1/messages (criar mensagem + sentiment)
  # Custom SentimentAnalyzer - Sentiment analysis in Portuguese/English
  
  POSITIVE_WORDS = %w[bom boa excelente ótimo maravilhoso feliz alegre positivo legal massa top show good great amazing happy].freeze
  NEGATIVE_WORDS = %w[ruim péssimo horrível triste negativo chato bosta lixo odiei desastre bad awful horrible sad negative].freeze

  def self.analyze(text)
    return 0.0 if text.blank?

    words = text.downcase.scan(/\w+/)
    positive_count = (words & POSITIVE_WORDS).size
    negative_count = (words & NEGATIVE_WORDS).size

    total_matches = positive_count + negative_count
    return 0.0 if total_matches.zero?

    # Score between -1.0 and 1.0
    (positive_count - negative_count).to_f / total_matches
  end
end
