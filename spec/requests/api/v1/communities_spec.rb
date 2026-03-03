require "rails_helper"

RSpec.describe "Api::V1::Communities", type: :request do
  let!(:community) { create(:community, name: "Test Community") }
  let!(:users) { create_list(:user, 3) }
  let!(:messages) do
    m1 = create(:message, user: users[0], username: users[0].username, community: community, content: "Message 1")
    m2 = create(:message, user: users[1], username: users[1].username, community: community, content: "Message 2")
    m3 = create(:message, user: users[2], username: users[2].username, community: community, content: "Message 3")
    [m1, m2, m3]
  end

  describe "GET /api/v1/communities/:id/messages/top" do
    context "with valid community" do
      it "returns top messages sorted by reaction count" do
        create(:reaction, message: messages[0], user: users[0], reaction_type: "like")
        create(:reaction, message: messages[0], user: users[1], reaction_type: "like")
        create(:reaction, message: messages[1], user: users[2], reaction_type: "heart")

        get "/api/v1/communities/#{community.id}/messages/top"

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["community_id"]).to eq(community.id)
        expect(response.parsed_body["data"].first["reaction_count"]).to eq(2)
      end

      it "respects custom limit parameter" do
        create(:reaction, message: messages[0], user: users[0], reaction_type: "like")

        get "/api/v1/communities/#{community.id}/messages/top", params: {limit: 1}

        expect(response.parsed_body["data"].length).to eq(1)
      end

      it "returns empty array when no messages exist" do
        empty_community = create(:community, name: "Empty Community")

        get "/api/v1/communities/#{empty_community.id}/messages/top"

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["data"]).to be_empty
      end

      it "includes reaction_count in response" do
        get "/api/v1/communities/#{community.id}/messages/top"

        expect(response.parsed_body["data"].first).to have_key("reaction_count")
      end
    end

    context "with invalid community" do
      it "returns not found error" do
        get "/api/v1/communities/999999/messages/top"

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body["error"]).to eq("Community not found")
      end
    end
  end
end
