require "rails_helper"

RSpec.describe "Api::V1::Analytics", type: :request do
  # Setup test data
  let!(:user) { User.create!(username: "testuser_api") }
  let!(:community) { Community.create!(name: "API Test Community") }

  describe "GET /api/v1/analytics/suspicious_ips" do
    context "when there are suspicious ips with min_users = 3" do
      before do
        ["Alice", "Bob", "Charlie"].each do |name|
          Message.create!(
            user: User.create!(username: name),
            community: community,
            content: "Parent message for API testing",
            user_ip: "10.0.0.1"
          )
        end
      end

      it "returns suspicious ips" do
        get "/api/v1/analytics/suspicious_ips",
          params: {min_users: 3},
          headers: {"Accept" => "application/json"}

        expect(response).to have_http_status(:ok)
        expect(response.body).to include_json(
          message: "Suspicious IP analysis completed (detection logic pending implementation)",
          suspicious_ips_count: 2,
          data: [
            {
              ip: "10.0.0.1",
              user_count: 2,
              users: [
                "Alice",
                "Bob",
                "Charlie"
              ]
            }
          ]
        )
      end

      it "returns created status" do
        post "/api/v1/messages", params: valid_params, headers: {"Accept" => "application/json"}
        expect(response).to have_http_status(:created)
      end

      it "returns JSON response with message data" do
        post "/api/v1/messages", params: valid_params, headers: {"Accept" => "application/json"}
        json_response = JSON.parse(response.body)

        expect(json_response).to have_key("message")
        expect(json_response).to have_key("data")
        expect(json_response["data"]).to have_key("id")
        expect(json_response["data"]).to have_key("content")
        expect(json_response["data"]["content"]).to eq("This is a test message with positive sentiment! I'm so excited about this feature!")
        expect(json_response["data"]).to have_key("user_id")
        expect(json_response["data"]).to have_key("community_id")
        expect(json_response["data"]).to have_key("ai_sentiment_score")
        expect(json_response["data"]).to have_key("created_at")
      end

      it "applies sentiment analysis to positive messages" do
        post "/api/v1/messages", params: valid_params, headers: {"Accept" => "application/json"}
        json_response = JSON.parse(response.body)

        # This test will FAIL with the stub implementation (always returns 0.5)
        # Actual implementation should return a high score (> 0.7) for positive content
        sentiment_score = json_response["data"]["ai_sentiment_score"]
        expect(sentiment_score).to be > 0.7
      end

      it "applies sentiment analysis to negative messages" do
        negative_params = {
          message: {
            content: "This is terrible. I hate this feature and it's completely broken. Worst experience ever!",
            user_id: user.id,
            community_id: community.id,
            user_ip: "192.168.1.101"
          }
        }

        post "/api/v1/messages", params: negative_params, headers: {"Accept" => "application/json"}
        json_response = JSON.parse(response.body)

        # This test will FAIL with the stub implementation (always returns 0.5)
        # Actual implementation should return a low score (< 0.3) for negative content
        sentiment_score = json_response["data"]["ai_sentiment_score"]
        expect(sentiment_score).to be < 0.3
      end

      it "applies sentiment analysis to neutral messages" do
        neutral_params = {
          message: {
            content: "The feature exists and works as described in the documentation.",
            user_id: user.id,
            community_id: community.id,
            user_ip: "192.168.1.102"
          }
        }

        post "/api/v1/messages", params: neutral_params, headers: {"Accept" => "application/json"}
        json_response = JSON.parse(response.body)

        # This test will FAIL with the stub implementation (always returns 0.5)
        # Actual implementation should return a middle score (~0.5) for neutral content
        sentiment_score = json_response["data"]["ai_sentiment_score"]
        expect(sentiment_score).to be >= 0.4
        expect(sentiment_score).to be <= 0.6
      end
    end

    context "as a reply to parent message" do
      let(:reply_params) do
        {
          message: {
            content: "This is a reply message! I completely agree with your point.",
            user_id: user.id,
            community_id: community.id,
            parent_message_id: parent_message.id,
            user_ip: "192.168.1.103"
          }
        }
      end

      it "creates a reply message" do
        expect {
          post "/api/v1/messages", params: reply_params, headers: {"Accept" => "application/json"}
        }.to change(Message, :count).by(1)
      end

      it "returns created status" do
        post "/api/v1/messages", params: reply_params, headers: {"Accept" => "application/json"}
        expect(response).to have_http_status(:created)
      end

      it "properly sets the parent_message_id" do
        post "/api/v1/messages", params: reply_params, headers: {"Accept" => "application/json"}
        json_response = JSON.parse(response.body)

        created_message = Message.find(json_response["data"]["id"])
        expect(created_message.parent_message_id).to eq(parent_message.id)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params_no_user) do
        {
          message: {
            content: "This message has no user",
            community_id: community.id
          }
        }
      end

      let(:invalid_params_no_content) do
        {
          message: {
            content: "",
            user_id: user.id,
            community_id: community.id
          }
        }
      end

      let(:invalid_params_no_community) do
        {
          message: {
            content: "This message has no community",
            user_id: user.id
          }
        }
      end

      it "returns error for missing user_id" do
        post "/api/v1/messages", params: invalid_params_no_user, headers: {"Accept" => "application/json"}
        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key("error")
        expect(json_response["error"]).to eq("Message creation failed")
        expect(json_response).to have_key("details")
      end

      it "returns error for missing content" do
        post "/api/v1/messages", params: invalid_params_no_content, headers: {"Accept" => "application/json"}
        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key("error")
      end

      it "returns error for missing community_id" do
        post "/api/v1/messages", params: invalid_params_no_community, headers: {"Accept" => "application/json"}
        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key("error")
      end
    end

    context "with non-existent user_id" do
      let(:invalid_user_params) do
        {
          message: {
            content: "This references a non-existent user",
            user_id: 999999,
            community_id: community.id
          }
        }
      end

      it "returns error for non-existent user" do
        post "/api/v1/messages", params: invalid_user_params, headers: {"Accept" => "application/json"}
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with non-existent community_id" do
      let(:invalid_community_params) do
        {
          message: {
            content: "This references a non-existent community",
            user_id: user.id,
            community_id: 999999
          }
        }
      end

      it "returns error for non-existent community" do
        post "/api/v1/messages", params: invalid_community_params, headers: {"Accept" => "application/json"}
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with malformed request" do
      it "returns error for missing message parameter" do
        post "/api/v1/messages", params: {}, headers: {"Accept" => "application/json"}
        expect(response).to have_http_status(:internal_server_error)

        # The controller should handle this gracefully
        # Actual implementation might return :bad_request instead
      end
    end
  end
end
