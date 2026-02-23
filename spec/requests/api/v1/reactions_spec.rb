require "rails_helper"

RSpec.describe "Api::V1::Reactions", type: :request do
  # Setup test data
  let!(:user) { User.create!(username: "testuser_reactions") }
  let!(:user2) { User.create!(username: "anotheruser_reactions") }
  let!(:community) { Community.create!(name: "Reactions Test Community") }
  let!(:message) { Message.create!(user: user, community: community, content: "Test message for reactions API") }

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
        expect {
          post "/api/v1/reactions", params: valid_params, headers: {"Accept" => "application/json"}
        }.to change(Reaction, :count).by(1)
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
        expect(json_response["data"]).to have_key("reaction_type")
        expect(json_response["data"]["reaction_type"]).to eq("like")
        expect(json_response["data"]).to have_key("message_id")
        expect(json_response["data"]).to have_key("user_id")
        expect(json_response["data"]).to have_key("created_at")
      end

      it "supports different reaction types" do
        reaction_types = ["heart", "fire", "party", "rocket", "laugh", "sad", "angry"]

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

          # Clean up for next iteration
          Reaction.last.destroy
        end
      end
    end

    context "with concurrency protection" do
      # These tests verify that the API prevents duplicate reactions from the same user
      # on the same message, even under race conditions
      before do
        Reaction.delete_all
      end

      it "prevents duplicate reactions from same user on same message (simulated race condition)" do
        # First reaction should succeed
        params = {
          reaction: {
            reaction_type: "like",
            user_id: user.id,
            message_id: message.id
          }
        }

        # Create the first reaction
        post "/api/v1/reactions", params: params, headers: {"Accept" => "application/json"}
        expect(response).to have_http_status(:created)
        expect(Reaction.count).to eq(1)

        # Attempt to create the same reaction again (simulating race condition)
        # This should fail with concurrency protection
        post "/api/v1/reactions", params: params, headers: {"Accept" => "application/json"}

        # The implementation should return :conflict status (409)
        # to indicate the duplicate reaction was prevented
        # This test will FAIL with the stub implementation which doesn't check for duplicates
        expect(response).to have_http_status(:conflict)

        # Verify only one reaction exists
        expect(Reaction.count).to eq(1)
      end

      it "allows different reaction types from same user on same message" do
        # Create first reaction
        post "/api/v1/reactions",
          params: {reaction: {reaction_type: "like", user_id: user.id, message_id: message.id}},
          headers: {"Accept" => "application/json"}
        expect(response).to have_http_status(:created)

        # Create second reaction with different type
        post "/api/v1/reactions",
          params: {reaction: {reaction_type: "heart", user_id: user.id, message_id: message.id}},
          headers: {"Accept" => "application/json"}

        # This should succeed (different reaction type)
        # The stub will allow this, but actual implementation might need to define business rules
        expect(response).to have_http_status(:created)
        expect(Reaction.count).to eq(2)
      end

      it "allows same reaction type from different users on same message" do
        # Create reaction from user 1
        post "/api/v1/reactions",
          params: {reaction: {reaction_type: "like", user_id: user.id, message_id: message.id}},
          headers: {"Accept" => "application/json"}
        expect(response).to have_http_status(:created)

        # Create same reaction from user 2
        post "/api/v1/reactions",
          params: {reaction: {reaction_type: "like", user_id: user2.id, message_id: message.id}},
          headers: {"Accept" => "application/json"}

        expect(response).to have_http_status(:created)
        expect(Reaction.count).to eq(2)
      end

      it "handles concurrent requests with proper database locking (simulated)" do
        # This test simulates multiple concurrent requests trying to create the same reaction
        # The actual implementation should use database transactions, optimistic locking,
        # or unique constraints to prevent duplicates

        successful_creations = 0
        conflict_responses = 0

        # Simulate 5 concurrent requests
        5.times do |i|
          post "/api/v1/reactions",
            params: {reaction: {reaction_type: "fire", user_id: user.id, message_id: message.id}},
            headers: {"Accept" => "application/json"}

          if response.status == 201
            successful_creations += 1
          elsif response.status == 409
            conflict_responses += 1
          end

          # Clean up if created
          Reaction.last.destroy if response.status == 201
        end

        # With proper concurrency protection, only 1 request should succeed
        # and 4 should return conflict (409)
        # This test will FAIL with stub implementation which allows all requests
        expect(successful_creations).to eq(1)
        expect(conflict_responses).to eq(4)
        expect(Reaction.count).to eq(0) # All should be cleaned up
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

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key("error")
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

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key("error")
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

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key("error")
      end

      it "returns error for non-existent user_id" do
        invalid_params = {
          reaction: {
            reaction_type: "like",
            user_id: 999999,
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
            message_id: 999999
          }
        }

        post "/api/v1/reactions", params: invalid_params, headers: {"Accept" => "application/json"}
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with malformed request" do
      it "returns error for missing reaction parameter" do
        post "/api/v1/reactions", params: {}, headers: {"Accept" => "application/json"}
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end
end
