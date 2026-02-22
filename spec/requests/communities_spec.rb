require "rails_helper"

RSpec.describe "/communities", type: :request do
  let(:valid_attributes) {
    {name: "Ruby Developers", description: "A community for Ruby developers"}
  }

  let(:invalid_attributes) {
    {name: nil, description: "Test"}
  }

  let(:new_attributes) {
    {name: "Rails Developers", description: "A community for Rails developers"}
  }

  describe "GET /index" do
    it "renders a successful response" do
      Community.create! valid_attributes
      get communities_url
      expect(response).to be_successful
    end

    it "returns all communities" do
      Community.create! valid_attributes
      Community.create! name: "Python Devs", description: "Python community"
      get communities_url
      expect(Community.count).to eq(2)
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      community = Community.create! valid_attributes
      get community_url(community)
      expect(response).to be_successful
    end

    it "shows correct community data" do
      community = Community.create! valid_attributes
      get community_url(community)
      expect(response.body).to include("Ruby Developers")
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_community_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      community = Community.create! valid_attributes
      get edit_community_url(community)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Community" do
        expect {
          post communities_url, params: {community: valid_attributes}
        }.to change(Community, :count).by(1)
      end

      it "redirects to the created community" do
        post communities_url, params: {community: valid_attributes}
        expect(response).to redirect_to(community_url(Community.last))
      end

      it "creates community with correct data" do
        post communities_url, params: {community: valid_attributes}
        community = Community.last
        expect(community.name).to eq("Ruby Developers")
      end
    end

    context "with only name" do
      it "creates community without description" do
        expect {
          post communities_url, params: {community: {name: "Test Community"}}
        }.to change(Community, :count).by(1)
      end
    end

    context "with invalid parameters" do
      it "does not create a new Community" do
        expect {
          post communities_url, params: {community: invalid_attributes}
        }.to change(Community, :count).by(0)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      it "updates the requested community" do
        community = Community.create! valid_attributes
        patch community_url(community), params: {community: new_attributes}
        community.reload
        expect(community.name).to eq("Rails Developers")
      end

      it "redirects to the community" do
        community = Community.create! valid_attributes
        patch community_url(community), params: {community: new_attributes}
        expect(response).to redirect_to(community_url(community))
      end

      it "updates description only" do
        community = Community.create! valid_attributes
        patch community_url(community), params: {community: {description: "New description"}}
        community.reload
        expect(community.description).to eq("New description")
      end
    end

    context "with invalid parameters" do
      it "does not update the community" do
        community = Community.create! valid_attributes
        patch community_url(community), params: {community: invalid_attributes}
        community.reload
        expect(community.name).to eq("Ruby Developers")
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested community" do
      community = Community.create! valid_attributes
      expect {
        delete community_url(community)
      }.to change(Community, :count).by(-1)
    end

    it "redirects to the communities list" do
      community = Community.create! valid_attributes
      delete community_url(community)
      expect(response).to redirect_to(communities_url)
    end

    it "destroys associated messages" do
      community = Community.create! valid_attributes
      user = User.create!(username: "testuser")
      Message.create!(user: user, community: community, content: "Test message")
      expect {
        delete community_url(community)
      }.to change(Message, :count).by(-1)
    end
  end
end
