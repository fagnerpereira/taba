require "rails_helper"

RSpec.describe "Api::V1::Reactions", type: :request do
  let!(:user) { User.create!(username: "testuser") }
  let!(:community) { Community.create!(name: "Test Community") }
  let!(:message) { Message.create!(user: user, community: community, content: "Hello", user_ip: "127.0.0.1") }

  describe "POST /api/v1/reactions" do
    let(:valid_params) do
      {
        reaction: {
          message_id: message.id,
          user_id: user.id,
          reaction_type: "❤️"
        }
      }
    end

    it "creates a reaction" do
      # Referring to TODO: POST /api/v1/reactions (com proteção de concorrência)
      expect {
        post api_v1_reactions_path, params: valid_params
      }.to change(Reaction, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it "prevents duplicate reactions" do
      # Referring to TODO: POST /api/v1/reactions (com proteção de concorrência)
      Reaction.create!(user: user, message: message, reaction_type: "❤️")
      post api_v1_reactions_path, params: valid_params
      expect(response).to have_http_status(:conflict)
    end
  end
end
