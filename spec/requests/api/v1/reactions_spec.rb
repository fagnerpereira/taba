require "rails_helper"

RSpec.describe "Api::V1::Reactions", type: :request do
  let!(:user) { User.create!(username: "testuser_reactions") }
  let!(:user2) { User.create!(username: "anotheruser_reactions") }
  let!(:community) { Community.create!(name: "Reactions Test Community") }
  let!(:message) do
    Message.create!(user: user, username: user.username, community: community,
      content: "Test message for reactions API", user_ip: "127.0.0.1")
  end

  describe "POST /api/v1/reactions" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          reaction: {
            reaction_type: "like",
            user_id: user.id,
            message_id: message.id
          }
        }
      end

      it "creates a new reaction" do
        expect do
          post "/api/v1/reactions", params: valid_params, headers: {"Accept" => "application/json"}
        end.to change(Reaction, :count).by(1)
      end

      it "returns created status" do
        post "/api/v1/reactions", params: valid_params, headers: {"Accept" => "application/json"}
        expect(response).to have_http_status(:created)
      end

      it "returns JSON response with reaction data" do
        post "/api/v1/reactions", params: valid_params, headers: {"Accept" => "application/json"}
        json_response = JSON.parse(response.body)

        expect(json_response).to have_key("message")
        expect(json_response).to have_key("data")
        expect(json_response["data"]).to have_key("id")
        expect(json_response["data"]["reaction_type"]).to eq("like")
        expect(json_response["data"]).to have_key("message_id")
        expect(json_response["data"]).to have_key("user_id")
        expect(json_response["data"]).to have_key("created_at")
      end

      it "supports different reaction types" do
        reaction_types = %w[heart fire party rocket laugh sad angry]

        reaction_types.each do |reaction_type|
          params = {
            reaction: {
              reaction_type: reaction_type,
              user_id: user.id,
              message_id: message.id
            }
          }

          post "/api/v1/reactions", params: params, headers: {"Accept" => "application/json"}
          expect(response).to have_http_status(:created)
          expect(Reaction.last.reaction_type).to eq(reaction_type)

          Reaction.last.destroy
        end
      end
    end

    context "allows multiple reactions from different users" do
      it "allows same reaction type from different users on same message" do
        post "/api/v1/reactions",
          params: {reaction: {reaction_type: "like", user_id: user.id, message_id: message.id}},
          headers: {"Accept" => "application/json"}
        expect(response).to have_http_status(:created)

        post "/api/v1/reactions",
          params: {reaction: {reaction_type: "like", user_id: user2.id, message_id: message.id}},
          headers: {"Accept" => "application/json"}

        expect(response).to have_http_status(:created)
        expect(Reaction.count).to eq(2)
      end
    end

    context "with invalid parameters" do
      it "returns error for missing reaction_type" do
        invalid_params = {
          reaction: {
            user_id: user.id,
            message_id: message.id
          }
        }

        post "/api/v1/reactions", params: invalid_params, headers: {"Accept" => "application/json"}
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns error for missing user_id" do
        invalid_params = {
          reaction: {
            reaction_type: "like",
            message_id: message.id
          }
        }

        post "/api/v1/reactions", params: invalid_params, headers: {"Accept" => "application/json"}
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns error for missing message_id" do
        invalid_params = {
          reaction: {
            reaction_type: "like",
            user_id: user.id
          }
        }

        post "/api/v1/reactions", params: invalid_params, headers: {"Accept" => "application/json"}
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns error for non-existent user_id" do
        invalid_params = {
          reaction: {
            reaction_type: "like",
            user_id: 999_999,
            message_id: message.id
          }
        }

        post "/api/v1/reactions", params: invalid_params, headers: {"Accept" => "application/json"}
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns error for non-existent message_id" do
        invalid_params = {
          reaction: {
            reaction_type: "like",
            user_id: user.id,
            message_id: 999_999
          }
        }

        post "/api/v1/reactions", params: invalid_params, headers: {"Accept" => "application/json"}
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with malformed request" do
      it "returns error for missing reaction parameter" do
        post "/api/v1/reactions", params: {}, headers: {"Accept" => "application/json"}
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
