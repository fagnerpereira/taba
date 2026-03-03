require "rails_helper"

RSpec.describe "Api::V1::Messages", type: :request do
  let!(:community) { Community.create!(name: "Test Community") }

  describe "POST /api/v1/messages" do
    let(:valid_params) do
      {
        username: "testuser",
        community_id: community.id,
        content: "This is a great message!",
        user_ip: "127.0.0.1"
      }
    end

    it "creates a new message and user" do
      # Referring to TODO: POST /api/v1/messages (criar mensagem + sentiment)
      expect {
        post api_v1_messages_path, params: valid_params
      }.to change(Message, :count).by(1).and change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["ai_sentiment_score"]).to be > 0
    end

    it "returns error for invalid params" do
      # Referring to TODO: Validações implementadas
      post api_v1_messages_path, params: { content: "" }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
