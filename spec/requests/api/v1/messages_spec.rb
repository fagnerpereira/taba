require "rails_helper"

RSpec.describe Api::V1::MessagesController, type: :request do
  let!(:user) { create(:user) }
  let!(:community) { create(:community) }

  describe "POST /api/v1/messages" do
    let(:valid_params) do
      {
        message: {
          username: username,
          content: "Hello, this is a test message!",
          community_id: community.id,
          user_ip: "192.168.1.100"
        }
      }
    end

    context "with existing user" do
      let(:username) { user.username }

      it "creates a message successfully" do
        expect do
          post "/api/v1/messages", params: valid_params, as: :json
        end.to change(Message, :count).by(1)
          .and change(User, :count).by(0)

        expect(response).to have_http_status(:created)
      end

      it "returns correct message response" do
        post "/api/v1/messages", params: valid_params, as: :json

        message = Message.last
        expect(response.parsed_body).to include(
          id: message.id,
          content: message.content,
          user: {id: user.id, username: user.username},
          community_id: community.id,
          parent_message_id: nil,
          ai_sentiment_score: 0.0
        )
      end
    end

    context "with new user" do
      let(:username) { "new_user" }

      it "creates message and new user" do
        expect do
          post "/api/v1/messages", params: valid_params, as: :json
        end.to change(Message, :count).by(1)
          .and change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(Message.last.user.username).to eq("new_user")
      end
    end

    context "as a reply to parent message" do
      let!(:parent_message) do
        create(:message, user: user, username: user.username, community: community, content: "Parent message")
      end

      let(:reply_params) do
        {
          message: {
            username: user.username,
            content: "This is a reply!",
            community_id: community.id,
            user_ip: "192.168.1.100",
            parent_message_id: parent_message.id,
            ai_sentiment_score: 0.0
          }
        }
      end

      it "creates a reply message" do
        expect do
          post "/api/v1/messages", params: reply_params, as: :json
        end.to change(Message, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(Message.last.parent_message_id).to eq(parent_message.id)
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        {
          message: {
            username: "",
            content: "",
            community_id: "",
            user_ip: ""
          }
        }
      end

      it "returns validation errors" do
        post "/api/v1/messages", params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body).to include(
          "username" => ["can't be blank"],
          "content" => ["can't be blank"],
          "community" => ["must exist"],
          "user_ip" => ["can't be blank"]
        )
      end
    end
  end
end
