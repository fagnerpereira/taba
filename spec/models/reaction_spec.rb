require "rails_helper"

RSpec.describe Reaction, type: :model do
  it { should belong_to(:message) }
  it { should belong_to(:user) }
end
