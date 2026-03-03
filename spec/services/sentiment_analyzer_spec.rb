require "rails_helper"

RSpec.describe SentimentAnalyzer do
  describe ".analyze" do
    it "scores positive text correctly" do
      # Referring to TODO: POST /api/v1/messages (criar mensagem + sentiment)
      expect(SentimentAnalyzer.analyze("bom excelente ótimo")).to eq(1.0)
    end

    it "scores negative text correctly" do
      # Referring to TODO: POST /api/v1/messages (criar mensagem + sentiment)
      expect(SentimentAnalyzer.analyze("ruim péssimo lixo")).to eq(-1.0)
    end

    it "scores mixed text correctly" do
      # Referring to TODO: POST /api/v1/messages (criar mensagem + sentiment)
      expect(SentimentAnalyzer.analyze("bom ruim")).to eq(0.0)
    end
  end
end
