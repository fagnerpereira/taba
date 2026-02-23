require "rails_helper"

RSpec.describe "/users", type: :request do
  let(:valid_attributes) {
    {username: "johndoe"}
  }

  let(:invalid_attributes) {
    {username: nil}
  }

  let(:new_attributes) {
    {username: "janedoe"}
  }

  describe "GET /index" do
    it "renders a successful response" do
      User.create! valid_attributes
      get users_url
      expect(response).to be_successful
    end

    it "returns all users" do
      User.create! valid_attributes
      User.create! username: "janedoe"
      get users_url
      expect(User.count).to eq(2)
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      user = User.create! valid_attributes
      get user_url(user)
      expect(response).to be_successful
    end

    it "shows correct user data" do
      user = User.create! valid_attributes
      get user_url(user)
      expect(response.body).to include("johndoe")
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_user_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      user = User.create! valid_attributes
      get edit_user_url(user)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new User" do
        expect {
          post users_url, params: {user: valid_attributes}
        }.to change(User, :count).by(1)
      end

      it "redirects to the created user" do
        post users_url, params: {user: valid_attributes}
        expect(response).to redirect_to(user_url(User.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new User" do
        expect {
          post users_url, params: {user: invalid_attributes}
        }.to change(User, :count).by(0)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      it "updates the requested user" do
        user = User.create! valid_attributes
        patch user_url(user), params: {user: new_attributes}
        user.reload
        expect(user.username).to eq("janedoe")
      end

      it "redirects to the user" do
        user = User.create! valid_attributes
        patch user_url(user), params: {user: new_attributes}
        expect(response).to redirect_to(user_url(user))
      end
    end

    context "with invalid parameters" do
      it "does not update the user" do
        user = User.create! valid_attributes
        patch user_url(user), params: {user: invalid_attributes}
        user.reload
        expect(user.username).to eq("johndoe")
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested user" do
      user = User.create! valid_attributes
      expect {
        delete user_url(user)
      }.to change(User, :count).by(-1)
    end

    it "redirects to the users list" do
      user = User.create! valid_attributes
      delete user_url(user)
      expect(response).to redirect_to(users_url)
    end

    it "destroys associated messages" do
      user = User.create! valid_attributes
      community = Community.create!(name: "Test Community")
      Message.create!(user: user, community: community, content: "Test")
      expect {
        delete user_url(user)
      }.to change(Message, :count).by(-1)
    end

    it "destroys associated reactions" do
      user = User.create! valid_attributes
      community = Community.create!(name: "Test Community")
      message = Message.create!(user: user, community: community, content: "Test")
      Reaction.create!(user: user, message: message, reaction_type: "like")
      expect {
        delete user_url(user)
      }.to change(Reaction, :count).by(-1)
    end
  end
end
