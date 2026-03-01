FactoryBot.define do
  factory :community do
    sequence(:name) { |n| "Community #{n}" }
  end
end
