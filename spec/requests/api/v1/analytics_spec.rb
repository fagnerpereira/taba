require "rails_helper"

RSpec.describe "Api::V1::Analytics", type: :request do
  let!(:community) { create(:community, name: "Test Community") }
  let!(:users) { create_list(:user, 4) }

  describe "GET /api/v1/analytics/suspicious_ips" do
    context "with suspicious IPs (same IP used by multiple users)" do
      before do
        create(:message, user: users[0], username: users[0].username, community: community,
          content: "Message from user 1", user_ip: "10.0.0.1")
        create(:message, user: users[1], username: users[1].username, community: community,
          content: "Message from user 2", user_ip: "10.0.0.1")
        create(:message, user: users[2], username: users[2].username, community: community,
          content: "Message from user 3", user_ip: "10.0.0.2")
        create(:message, user: users[3], username: users[3].username, community: community,
          content: "Message from user 4", user_ip: "10.0.0.2")
      end

      it "returns suspicious IPs with multiple users" do
        get "/api/v1/analytics/suspicious_ips", params: {min_users: 2}

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["suspicious_ips_count"]).to eq(2)
      end

      it "filters by minimum users threshold" do
        get "/api/v1/analytics/suspicious_ips", params: {min_users: 3}

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["suspicious_ips_count"]).to eq(0)
      end

      it "includes user count and usernames in response" do
        get "/api/v1/analytics/suspicious_ips", params: {min_users: 2}

        expect(response).to have_http_status(:ok)
        data = response.parsed_body["data"]
        expect(data.first["user_count"]).to eq(2)
        expect(data.first["users"]).to include(users[0].username, users[1].username)
      end
    end

    context "with no suspicious IPs" do
      before do
        users.each_with_index do |user, i|
          create(:message, user: user, username: user.username, community: community, content: "Message #{i}",
            user_ip: "10.0.0.#{i + 1}")
        end
      end

      it "returns empty array when no suspicious IPs found" do
        get "/api/v1/analytics/suspicious_ips", params: {min_users: 2}

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["data"]).to be_empty
      end
    end

    context "with default parameters" do
      it "uses default min_users value when not provided" do
        get "/api/v1/analytics/suspicious_ips"

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
