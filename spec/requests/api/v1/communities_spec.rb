require "rails_helper"

RSpec.describe "Api::V1::Communities", type: :request do
  let!(:community) { Community.create!(name: "Test Community") }
  let!(:user) { User.create!(username: "user") }
  
  describe "GET /api/v1/communities/:id/messages/top" do
    it "returns top messages ordered by engagement" do
      # Referring to TODO: GET /api/v1/communities/:id/messages/top
      m1 = Message.create!(user: user, community: community, content: "Low engagement", user_ip: "1.1.1.1")
      m2 = Message.create!(user: user, community: community, content: "High engagement", user_ip: "1.1.1.1")
      
      Reaction.create!(user: user, message: m2, reaction_type: "❤️")
      Message.create!(user: user, community: community, content: "Reply", user_ip: "1.1.1.1", parent_message: m2)

      get top_messages_api_v1_community_path(community)
      
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["messages"].first["id"]).to eq(m2.id)
    end
  end
end
