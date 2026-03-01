require "rails_helper"

RSpec.describe User, type: :model do
  it { should have_many(:messages).dependent(:destroy) }
  it { should have_many(:reactions).dependent(:destroy) }
  it { should validate_presence_of(:username) }
end
