require "rails_helper"

RSpec.describe Message, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:community) }
    it { should belong_to(:parent_message).class_name("Message").optional }
    it { should have_many(:replies).class_name("Message").with_foreign_key("parent_message_id").dependent(:destroy) }
    it { should have_many(:reactions).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:user_ip) }
    it { should validate_presence_of(:username) }
  end

  describe "#analyze_sentiment" do
    context "when content is empty" do
      let(:message) { build(:message, content: "") }

      it "returns 0.0" do
        expect(message.analyze_sentiment).to eq(0.0)
      end
    end

    context "when content has positive words" do
      let(:message) { build(:message, content: "This is a great message") }

      it "returns a positive score" do
        expect(message.analyze_sentiment).to be(1.0)
      end
    end

    context "when content has negative words" do
      let(:message) { build(:message, content: "This is a bad message") }

      it "returns a negative score" do
        expect(message.analyze_sentiment).to be(-1.0)
      end
    end

    context "when content has neutral words" do
      let(:message) { build(:message, content: "This is a neutral message") }

      it "returns 0.0" do
        expect(message.analyze_sentiment).to eq(0.0)
      end
    end
  end

  describe "#set_user callback" do
    let(:community) { create(:community) }

    context "when user is provided" do
      let(:user) { create(:user) }
      let(:message) { build(:message, user: user, username: user.username, community: community) }

      it "keeps the existing user" do
        expect(message.user).to eq(user)
        expect(message).to be_valid
      end
    end

    context "when user is missing but username is present" do
      let(:username) { "new_user" }
      let(:message) { build(:message, user: nil, username: username, community: community) }

      it "creates a new user with the given username" do
        expect { message.valid? }.to change(User, :count).by(1)
        expect(message.user.username).to eq(username)
      end

      it "reuses existing user if username matches" do
        existing_user = create(:user, username: username)
        expect { message.valid? }.not_to change(User, :count)
        expect(message.user).to eq(existing_user)
      end
    end
  end
end
