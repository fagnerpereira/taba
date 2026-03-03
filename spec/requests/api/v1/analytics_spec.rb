require "rails_helper"

RSpec.describe "Api::V1::Analytics", type: :request do
  describe "GET /api/v1/analytics/suspicious_ips" do
    it "detects IPs used by multiple users" do
      # Referring to TODO: GET /api/v1/analytics/suspicious_ips
      community = Community.create!(name: "Test")
      u1 = User.create!(username: "u1")
      u2 = User.create!(username: "u2")
      u3 = User.create!(username: "u3")
      
      Message.create!(user: u1, community: community, content: "hi", user_ip: "1.2.3.4")
      Message.create!(user: u2, community: community, content: "hi", user_ip: "1.2.3.4")
      Message.create!(user: u3, community: community, content: "hi", user_ip: "1.2.3.4")

      get api_v1_analytics_suspicious_ips_path(min_users: 3)
      
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["suspicious_ips"].first["ip"]).to eq("1.2.3.4")
    end
  end
end
