require "rails_helper"

RSpec.describe "/reactions", type: :request do
  let(:user) { User.create!(username: "testuser") }
  let(:community) { Community.create!(name: "Test Community") }
  let(:message) { Message.create!(user: user, community: community, content: "Test message") }

  let(:valid_attributes) {
    {user_id: user.id, message_id: message.id, reaction_type: "like"}
  }

  let(:invalid_attributes) {
    {user_id: nil, message_id: message.id, reaction_type: "like"}
  }

  let(:new_attributes) {
    {reaction_type: "heart"}
  }

  describe "GET /index" do
    it "renders a successful response" do
      Reaction.create! valid_attributes
      get reactions_url
      expect(response).to be_successful
    end

    it "returns all reactions" do
      user2 = User.create!(username: "anotheruser")
      Reaction.create! valid_attributes
      Reaction.create!(user: user2, message: message, reaction_type: "heart")
      get reactions_url
      expect(Reaction.count).to eq(2)
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      reaction = Reaction.create! valid_attributes
      get reaction_url(reaction)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_reaction_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      reaction = Reaction.create! valid_attributes
      get edit_reaction_url(reaction)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Reaction" do
        expect {
          post reactions_url, params: {reaction: valid_attributes}
        }.to change(Reaction, :count).by(1)
      end

      it "redirects to the created reaction" do
        post reactions_url, params: {reaction: valid_attributes}
        expect(response).to redirect_to(reaction_url(Reaction.last))
      end

      it "creates reaction with correct type" do
        post reactions_url, params: {reaction: valid_attributes}
        expect(Reaction.last.reaction_type).to eq("like")
      end
    end

    context "with different reaction types" do
      it "creates reaction with heart type" do
        attrs = valid_attributes.merge(reaction_type: "heart")
        post reactions_url, params: {reaction: attrs}
        expect(Reaction.last.reaction_type).to eq("heart")
      end

      it "creates reaction with laugh type" do
        attrs = valid_attributes.merge(reaction_type: "laugh")
        post reactions_url, params: {reaction: attrs}
        expect(Reaction.last.reaction_type).to eq("laugh")
      end

      it "creates reaction with sad type" do
        attrs = valid_attributes.merge(reaction_type: "sad")
        post reactions_url, params: {reaction: attrs}
        expect(Reaction.last.reaction_type).to eq("sad")
      end

      it "creates reaction with angry type" do
        attrs = valid_attributes.merge(reaction_type: "angry")
        post reactions_url, params: {reaction: attrs}
        expect(Reaction.last.reaction_type).to eq("angry")
      end
    end

    context "with invalid parameters" do
      it "does not create a new Reaction without user" do
        expect {
          post reactions_url, params: {reaction: invalid_attributes}
        }.to change(Reaction, :count).by(0)
      end
    end

    context "with missing message_id" do
      it "does not create reaction without message" do
        attrs = {user_id: user.id, message_id: nil, reaction_type: "like"}
        expect {
          post reactions_url, params: {reaction: attrs}
        }.to change(Reaction, :count).by(0)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      it "updates the requested reaction" do
        reaction = Reaction.create! valid_attributes
        patch reaction_url(reaction), params: {reaction: new_attributes}
        reaction.reload
        expect(reaction.reaction_type).to eq("heart")
      end

      it "redirects to the reaction" do
        reaction = Reaction.create! valid_attributes
        patch reaction_url(reaction), params: {reaction: new_attributes}
        expect(response).to redirect_to(reaction_url(reaction))
      end
    end

    context "with invalid parameters" do
      it "does not update the reaction" do
        reaction = Reaction.create! valid_attributes
        original_type = reaction.reaction_type
        patch reaction_url(reaction), params: {reaction: invalid_attributes}
        reaction.reload
        expect(reaction.reaction_type).to eq(original_type)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested reaction" do
      reaction = Reaction.create! valid_attributes
      expect {
        delete reaction_url(reaction)
      }.to change(Reaction, :count).by(-1)
    end

    it "redirects to the reactions list" do
      reaction = Reaction.create! valid_attributes
      delete reaction_url(reaction)
      expect(response).to redirect_to(reactions_url)
    end
  end
end
