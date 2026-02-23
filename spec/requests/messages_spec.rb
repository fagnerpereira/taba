require "rails_helper"

RSpec.describe "/messages", type: :request do
  let(:user) { User.create!(username: "testuser") }
  let(:community) { Community.create!(name: "Test Community") }
  let(:parent_message) { Message.create!(user: user, community: community, content: "Parent message") }

  let(:valid_attributes) {
    {user_id: user.id, community_id: community.id, content: "Hello, world!"}
  }

  let(:invalid_attributes) {
    {user_id: nil, community_id: community.id, content: "Test"}
  }

  let(:new_attributes) {
    {content: "Updated message content"}
  }

  describe "GET /index" do
    it "renders a successful response" do
      Message.create! valid_attributes
      get messages_url
      expect(response).to be_successful
    end

    it "returns all messages" do
      Message.create! valid_attributes
      Message.create! user_id: user.id, community_id: community.id, content: "Another message"
      get messages_url
      expect(Message.count).to eq(2)
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      message = Message.create! valid_attributes
      get message_url(message)
      expect(response).to be_successful
    end

    it "shows correct message data" do
      message = Message.create! valid_attributes
      get message_url(message)
      expect(response.body).to include("Hello, world!")
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_message_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      message = Message.create! valid_attributes
      get edit_message_url(message)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Message" do
        expect {
          post messages_url, params: {message: valid_attributes}
        }.to change(Message, :count).by(1)
      end

      it "redirects to the created message" do
        post messages_url, params: {message: valid_attributes}
        expect(response).to redirect_to(message_url(Message.last))
      end

      it "creates message with correct content" do
        post messages_url, params: {message: valid_attributes}
        expect(Message.last.content).to eq("Hello, world!")
      end

      it "creates message with user_ip" do
        attrs = valid_attributes.merge(user_ip: "192.168.1.1")
        post messages_url, params: {message: attrs}
        expect(Message.last.user_ip).to eq("192.168.1.1")
      end

      it "creates message with ai_sentiment_score" do
        attrs = valid_attributes.merge(ai_sentiment_score: 0.85)
        post messages_url, params: {message: attrs}
        expect(Message.last.ai_sentiment_score).to eq(0.85)
      end
    end

    context "as reply to parent message" do
      it "creates reply message" do
        attrs = valid_attributes.merge(parent_message_id: parent_message.id)
        post messages_url, params: {message: attrs}
        expect(Message.last.parent_message_id).to eq(parent_message.id)
      end
    end

    context "with invalid parameters" do
      it "does not create a new Message" do
        expect {
          post messages_url, params: {message: invalid_attributes}
        }.to change(Message, :count).by(0)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      it "updates the requested message" do
        message = Message.create! valid_attributes
        patch message_url(message), params: {message: new_attributes}
        message.reload
        expect(message.content).to eq("Updated message content")
      end

      it "redirects to the message" do
        message = Message.create! valid_attributes
        patch message_url(message), params: {message: new_attributes}
        expect(response).to redirect_to(message_url(message))
      end

      it "updates user_ip" do
        message = Message.create! valid_attributes
        patch message_url(message), params: {message: {user_ip: "10.0.0.1"}}
        message.reload
        expect(message.user_ip).to eq("10.0.0.1")
      end

      it "updates ai_sentiment_score" do
        message = Message.create! valid_attributes
        patch message_url(message), params: {message: {ai_sentiment_score: 0.5}}
        message.reload
        expect(message.ai_sentiment_score).to eq(0.5)
      end
    end

    context "with invalid parameters" do
      it "does not update the message" do
        message = Message.create! valid_attributes
        original_content = message.content
        patch message_url(message), params: {message: invalid_attributes}
        message.reload
        expect(message.content).to eq(original_content)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested message" do
      message = Message.create! valid_attributes
      expect {
        delete message_url(message)
      }.to change(Message, :count).by(-1)
    end

    it "redirects to the messages list" do
      message = Message.create! valid_attributes
      delete message_url(message)
      expect(response).to redirect_to(messages_url)
    end

    it "destroys associated reactions" do
      message = Message.create! valid_attributes
      Reaction.create!(user: user, message: message, reaction_type: "like")
      expect {
        delete message_url(message)
      }.to change(Reaction, :count).by(-1)
    end

    it "destroys reply messages (cascading)" do
      message = Message.create! valid_attributes
      Message.create!(user: user, community: community, content: "Reply", parent_message: message)
      expect {
        delete message_url(message)
      }.to change(Message, :count).by(-2)
    end
  end
end
